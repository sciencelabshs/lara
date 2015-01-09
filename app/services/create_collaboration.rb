class CreateCollaboration
  # Output, these variables are initialized after successful call.
  attr_reader :collaboration_run, :owners_run, :owners_sequence_run

  def initialize(collaborators_data_url, user, material)
    @collaborators_data_url = collaborators_data_url
    # URI.parse(url).host returns nil when scheme is not provided.
    @portal_domain = URI(collaborators_data_url).host || URI("http://#{collaborators_data_url}")
    # Keep auth tokens for collaborations run separate (just in case).
    @auth_provider_name = Concord::AuthPortal.strategy_name_for_url(@portal_domain) + '_collaboration_run'
    @owner = user
    @activity = material.is_a?(LightweightActivity) ? material : nil
    @sequence = material.is_a?(Sequence) ? material : nil
    # Output.
    @collaboration_run = nil
    @owners_run = nil
    @owners_sequence_run = nil
  end

  # Setups collaboration and returns run or sequence run (depending on provided material type).
  def call
    ActiveRecord::Base.transaction do
      @collaboration_run = CollaborationRun.create!(
        user: @owner,
        collaborators_data_url: @collaborators_data_url
      )
      collaborators = get_collaborators_data
      process_collaborators_data(collaborators)
    end
    # Return run or sequence run that belongs to the collaboration owner.
    @owners_sequence_run || @owners_run
  end

  private

  def get_collaborators_data
    response = HTTParty.get(
      @collaborators_data_url, {
        :headers => {
          "Authorization" => Concord::AuthPortal.auth_token_for_url(@portal_domain),
          "Content-Type" => 'application/json'
        }
      }
    )
    fail 'Collaboration data cannot be obtained' if response.response.code != "200"
    JSON.parse(response.body)
  end

  def process_collaborators_data(collaborators)
    collaborators.each do |c|
      unless User.exists?(email: c['email'])
        user = User.create!(
          email:    c['email'],
          password: User.get_random_password
        )
      else
        user = User.find_by_email(c['email'])
      end
      update_auth_token(user, c['access_token'])
      # Well, RemotePortal is a single endpoint in fact. Naming isn't consistent at all.
      portal_endpoint = RemotePortal.new(
        returnUrl: c['endpoint_url'],
        externalId: c['learner_id']
      )
      add_activity_run(user, portal_endpoint) if @activity
      add_sequence_runs(user, portal_endpoint) if @sequence
    end
  end

  def update_auth_token(user, access_token)
    # Well, this is awkward. IMHO runs should have their own
    # tokens independent from users, but for now let's just follow
    # existing pattern... One strong assumption which is present everywhere
    # is that a given user is bound only to one portal. Due to random
    # emails generated by portals it's' be true, but still it's
    # confusing and perhaps incorrect.
    existing_auth = Authentication.where(user_id: user.id, provider: @auth_provider_name).first
    if existing_auth
      existing_auth.update_attributes!(token: access_token)
    else
      user.authentications.create!(
        provider: @auth_provider_name,
        token:    access_token
      )
    end
  end

  def add_activity_run(user, portal_endpoint)
    # for_user_and_portal is in fact lookup_or_create
    run = Run.for_user_and_portal(user, @activity, portal_endpoint)
    @collaboration_run.runs.push(run)
    # Save run that belongs to the collaboration owner.
    @owners_run = run if user == @owner
  end

  def add_sequence_runs(user, portal_endpoint)
    sequence_run = SequenceRun.lookup_or_create(@sequence, user, portal_endpoint)
    @collaboration_run.runs.push(*sequence_run.runs)
    # Save sequence run that belongs to the collaboration owner.
    @owners_sequence_run = sequence_run if user == @owner
  end

end
