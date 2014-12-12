class HomeController < ApplicationController
  def home
    if(params[:re_login])
      redirect_to user_omniauth_authorize_path(params[:provider])
    else
      @filter  = CollectionFilter.new(current_user, LightweightActivity, params[:filter] || {})
      # TODO: Add 'oficial' to the criteron?
      @activities = @filter.collection.includes(:user,:changed_by,:portal_publications).first(10)
      @filter.klass = Sequence
      # TODO: Add 'oficial' to the criteron?
      @sequences  = @filter.collection.includes(:user,:lightweight_activities).first(10)
    end
  end
  def bad_browser
    render "/home/bad_browser"
  end

end
