class PublicationsController < ApplicationController
  before_filter :setup
  # simplest object for rendering our views.  TODO: move elsewhere?
  class PortalStatus
    def initialize(concord_portal,publishable)
      @portal = concord_portal
      @publishable = publishable
    end

    def published?
      return @publishable.portal_publications.detect { |pp| pp.portal_url == @portal.publishing_url }
    end
    def id
      @portal.id
    end
    def name
      @portal.strategy_name
    end
    def url
      @portal.url
    end
  end
  
  def show_status
    @message = params[:message] || ''
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('show_status')}, :content_type => 'text/json' }
      format.html
    end
  end

  def remove_portal
    @portal = find_portal
    @publishable.remove_portal_publication(@portal)
    redirect_to show_status
  end

  def add_portal
    # TODO: we must not forget to actually publish this later, see publis_activity_path(activity)
    @portal = find_portal
    @message = ''
    @publishable.add_portal_publication(@portal)
    redirect_to :action => 'show_status'
  end

  private
  def find_portal
    Concord::AuthPortal.portal_for_url(params['portal_url'])
  end

  def setup
    type = params['publishable_type'].constantize
    id = params['publishable_id']
    @publishable = type.find(id)
    @portals = Concord::AuthPortal.all.values.map { |v| PortalStatus.new(v, @publishable) }
  end
end

