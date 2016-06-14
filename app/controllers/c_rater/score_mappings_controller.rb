class CRater::ScoreMappingsController < ApplicationController

  def index
    if current_user && current_user.admin?
      @filter = CollectionFilter.new(current_user, CRater::ScoreMapping, params[:filter] || {})
      @score_mappings = @filter.collection.includes(:user)
    else
      response_data = unauthorized_response_data("no_action", "no_resource")
      render :partial => "shared/unauthorized", :locals => {:message => response_data[:message]}, :status => 403
      return
    end
  end

  def new
    authorize! :manage, CRater::ScoreMapping
    @score_mapping = CRater::ScoreMapping.new()
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('new'), :css_class => "feedback-set" }, :content_type => 'text/json' }
      format.html
    end
  end

  def create
    authorize! :manage, CRater::ScoreMapping
    score_mapping = { mapping: params[:c_rater_score_mapping].slice(:score0,:score1,:score2,:score3,:score4,:score5,:score6)}
    @score_mapping = CRater::ScoreMapping.create(score_mapping)
    @score_mapping.description = params[:c_rater_score_mapping][:description]
    @score_mapping.user = current_user
    @score_mapping.changed_by = current_user
    @score_mapping.save
    redirect_to(:back)
  end

  def edit
    authorize! :manage, CRater::ScoreMapping
    @score_mapping = CRater::ScoreMapping.find(params[:id])
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('edit'), :css_class => "feedback-set"}, :content_type => 'text/json' }
      format.html
    end
  end

  def update
    authorize! :manage, CRater::ScoreMapping
    @score_mapping = CRater::ScoreMapping.find(params[:id])
    score_mapping = { mapping: params[:c_rater_score_mapping].slice(:score0,:score1,:score2,:score3,:score4,:score5,:score6)}
    @score_mapping.description = params[:c_rater_score_mapping][:description]
    @score_mapping.update_attributes(score_mapping)
    @score_mapping.changed_by = current_user
    @score_mapping.save!
    redirect_to(:back)
  end

  def destroy
    authorize! :manage, CRater::ScoreMapping
    @score_mapping = CRater::ScoreMapping.find(params[:id])
    @score_mapping.destroy
    redirect_to(:back)
  end
end
