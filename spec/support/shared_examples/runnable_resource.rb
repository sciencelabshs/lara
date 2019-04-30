# These shared examples are intended to be used for 5 show actions:
# /sequences/:id
# /sequences/:sequence_id/activities/:id
# /sequences/:sequence_id/activities/:activity_id/pages/:id
# /activities/:id
# /activities/:activity_id/pages/:id

# the /sequences/:id is the only one that works directly with sequence runs
# the rest work with activity runs and if they are part of sequence they will indirectly
# work with sequence runs
# there has to be a lot of variables to handle the sequence and activity run case
# it might not be worth the trouble, but it does make sure that any new features of runs
# should get added to sequence runs (if the tests get updated)

# this should be included in a controller and needs the following context
# base_params: the params passed to get as well as any route helpers
shared_examples "runnable launched without run_key" do |run_type|
  let (:running_user) { FactoryGirl.create(:user) }
  let (:run_factory_type) { run_type.model_name.underscore.to_sym}
  describe "when the user is anonymous" do
    it "redirects with a #{run_type} key in the URL" do
      result = get :show, base_params
      redirect_params = base_params.clone
      redirect_params[run_key_param_name] = assigns[run_variable_name]
      expect(result).to redirect_to(send(run_path_helper, redirect_params))
    end
    describe "when an anonymous #{run_type} already exists" do
      # we only build the new run and not create it so it won't be found by accident
      # if the lookup code is broken
      let(:new_run) { FactoryGirl.build(run_factory_type, base_factory_params) }
      let(:anon_factory_params){ base_factory_params.merge(user_id: nil) }
      let(:anon_run) { FactoryGirl.create(run_factory_type, anon_factory_params) }

      before(:each) {
        # create the anonymous run
        anon_run
      }
      it "creates a new #{run_type}, it does not use the existing #{run_type}" do
        # we save the new_run during creation because sequence runs create
        # activity runs on initialization and that requires a saved model
        expect(run_type).to receive(:create!) { new_run.save; new_run }
        get :show, base_params
        expect(assigns[run_variable_name]).to eq(new_run)
      end
    end
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in running_user
    end
    describe "when there is a #{run_type} owned by this user" do
      let (:extra_factory_params) { {} }
      let (:run_with_user_factory_params) { base_factory_params.merge(user_id: running_user.id) }
      let (:owned_run) {
        factory_params = run_with_user_factory_params.merge(extra_factory_params)
        FactoryGirl.create(run_factory_type, factory_params)
      }
      before(:each) {
        owned_run
      }
      describe "when this #{run_type} has no portal properties" do
        it "finds this existing #{run_type}" do
          get :show, base_params
          expect(assigns[run_variable_name]).to eq(owned_run)
        end
      end
      describe "when this #{run_type} has portal properties" do
        let (:extra_factory_params) { {remote_endpoint: 'http://example.com', remote_id: 1} }
        let (:new_run) { FactoryGirl.build(run_factory_type, run_with_user_factory_params) }

        it "creates a new #{run_type}, it does not use the existing #{run_type}" do
          expect(run_type).to receive(:create!) { new_run.save; new_run }
          get :show, base_params
          expect(assigns[run_variable_name]).to eq(new_run)
        end
      end
    end
  end
end

shared_examples "runnable launched with run_key" do |run_type, portal_launchable|
  let (:running_user) { FactoryGirl.create(:user) }
  let (:run_factory_type) { run_type.model_name.underscore.to_sym}
  describe "when there is no #{run_type} with this key" do
    it "returns 404" do
      params_with_invalid_run_key = base_params.clone()
      params_with_invalid_run_key[run_key_param_name] = UUIDTools::UUID.random_create.to_s
      expect{
        get :show, params_with_invalid_run_key
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "when there is an existing #{run_type} with this key" do
    let (:existing_run) { FactoryGirl.create(run_factory_type, existing_run_factory_params) }
    let (:params_with_existing_run_key) {
      params = base_params.clone()
      params[run_key_param_name] = existing_run.key
      params
    }
    before(:each){
      existing_run
    }

    describe "when the user is anonymous" do
      before(:each){
        get :show, params_with_existing_run_key
      }
      describe "when this #{run_type} is anonymous" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: nil) }
        it "finds this existing #{run_type}" do
          expect(assigns[run_variable_name]).to eq(existing_run)
        end
      end
      describe "but the #{run_type} is owned by a user" do
        let (:other_user) { FactoryGirl.create(:user) }
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: other_user.id) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end

        it 'renders unauthorized run message' do
          expect(response).to render_template('runs/unauthorized_run')
        end

        it 'uses the theme of the resource' do
          expect(assigns(:theme)).to eq(theme)
        end

        it 'uses the project of the resource' do
          expect(assigns(:project)).to eq(project)
        end

      end
    end

    describe "when a user is signed in" do
      before(:each) do
        sign_in running_user
        get :show, params_with_existing_run_key
      end
      describe "when this #{run_type} is anonymous" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: nil) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end
      end
      describe "when the #{run_type} is owned by a different user" do
        let (:other_user) { FactoryGirl.create(:user) }
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: other_user.id) }
        it "returns 403" do
          expect(response).to have_http_status(403)
        end
      end
      describe "when the #{run_type} is owned by the current user" do
        let (:existing_run_factory_params) { base_factory_params.merge(user_id: running_user.id) }
        describe "when this #{run_type} has no portal properties" do
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end
        end
        describe "when this existing #{run_type} has portal properties" do
          let (:existing_run_factory_params) {
            super().merge(remote_endpoint: 'http://example.com', remote_id: 1) }
          it "finds this existing #{run_type}" do
            expect(assigns[run_variable_name]).to eq(existing_run)
          end
        end
      end
    end
  end
end

shared_examples "runnable launched with portal parameters" do |run_type|
  let (:run_factory_type) { run_type.model_name.underscore.to_sym}
  let (:running_user) { FactoryGirl.create(:user) }
  let (:request_params_with_portal_properties) {
    base_params.merge(returnUrl: 'https:/example.com', externalId: 1)
  }
  let (:run_factory_portal_params) {
    { remote_endpoint: 'https:/example.com', remote_id: 1 }
  }
  describe "when the user is anonymous" do
    # perhaps this should be a 403, but perhaps we don't want people thinking they
    # can fish for valid portal properties
    it "returns 404" do
      expect {
        get :show, request_params_with_portal_properties
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe "when a user is signed in" do
    before(:each) do
      sign_in running_user
    end
    describe "when there is not a #{run_type} with matching user and portal params" do
      let(:anon_run_with_same_portal_params) {
        params = base_factory_params.merge(user_id: nil)
        params = params.merge(run_factory_portal_params)
        FactoryGirl.create(run_factory_type, params)
      }
      let(:other_user) { FactoryGirl.create(:user) }
      let(:other_user_run_with_same_portal_params) {
        params = base_factory_params.merge(user_id: other_user.id)
        params = params.merge(run_factory_portal_params)
        FactoryGirl.create(run_factory_type, params)
      }
      let (:new_run) {
        params = base_factory_params.merge(user_id: running_user.id)
        params = params.merge(run_factory_portal_params)
        FactoryGirl.build(run_factory_type, params)
      }

      it "redirects with a #{run_type} key in the URL" do
        result = get :show, request_params_with_portal_properties
        redirect_params = base_params.clone
        redirect_params[run_key_param_name] = assigns[run_variable_name]
        expect(result).to redirect_to(send(run_path_helper, redirect_params))
      end

      it "creates a #{run_type}" do
        expect(run_type).to receive(:create!) { new_run.save; new_run }
        get :show, request_params_with_portal_properties
        expect(assigns[run_variable_name]).to eq(new_run)
      end
    end
    describe "when there is a #{run_type} with matching portal params" do
      let (:matching_run) {
        params = base_factory_params.merge(user_id: running_user.id)
        params = params.merge(run_factory_portal_params)
        FactoryGirl.create(run_factory_type, params)
      }
      describe "when this #{run_type} is owned by the current user" do
        it "redirects to a URL with the #{run_type} key" do
          result = get :show, request_params_with_portal_properties
          redirect_params = base_params.clone
          redirect_params[run_key_param_name] = assigns[run_variable_name]
          expect(result).to redirect_to(send(run_path_helper, redirect_params))
        end
      end
    end
  end
end


shared_examples "runnable resource launchable by the portal" do |run_type|
  it_behaves_like "runnable launched without run_key", run_type
  it_behaves_like "runnable launched with run_key", run_type
  it_behaves_like "runnable launched with portal parameters", run_type
end

shared_examples "runnable resource not launchable by the portal" do |run_type|
  it_behaves_like "runnable launched without run_key", run_type
  it_behaves_like "runnable launched with run_key", run_type
  describe "when launched with portal parameters" do
    before(:each) do
      sign_in FactoryGirl.create(:user)
    end
    it "returns an error when launched with portal parameters" do
      with_portal_params = base_params.merge(returnUrl: 'https:/example.com', externalId: 1)
      expect {
        get :show, with_portal_params
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
