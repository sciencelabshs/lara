class PluginsController < ApplicationController

  private
  def _form(plugin, edit)
    render_to_string('_form', layout: false, locals: { plugin: @plugin, edit: edit })
  end

  public
  def edit
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    respond_to do |format|
      format.js {
        render :json => {
          html: _form(@plugin, true)
        }, :content_type => 'text/json'
      }
    end
  end

  def new
    authorize! :create, Plugin
    @activity = LightweightActivity.find(params[:activity_id])
    @plugin = @activity.plugins.create()
    respond_to do |format|
      format.js {
        render :json => {
          html: _form(@plugin, false)
        }
      }
    end
  end

  # PUT /plugins/1
  def update
    cancel = params[:commit] == "Cancel"
    @params = params
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    if !cancel
      @plugin.update_attributes(params['plugin'])
      @plugin.reload
    end

    respond_to do |format|
      format.js do
        # will render update.js.erb
      end
    end
  end

  # DELETE /plugins/1
  def destroy
    @plugin = Plugin.find(params[:id])
    authorize! :manage, @plugin
    @plugin.destroy
    respond_to do |format|
      format.js do
        # will render destroy.js.erb
      end
    end
  end
end
