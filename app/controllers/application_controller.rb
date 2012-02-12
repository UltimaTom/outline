class ApplicationController < ActionController::Base
  layout :themed_layout
  protect_from_forgery

  helper_method :current_user, :current_domain, :current_project, :logged_in?
  helper_method :themed, :try_translation

  before_filter :set_activity_user

  def themed_layout(layout = :application)
    "themes/#{current_theme}/#{layout}"
  end

  private

  def current_domain
    current_user.try(:domain)
  end

  def current_project
    @project ||= resource.respond_to?(:context) && resource.context.try(:resource).is_a?(Project) && resource.context.resource
  end

  def current_theme
    :default
  end
  
  def current_user
    @current_user ||= ::UserSession.find.try(:user)
  end
  alias logged_in? current_user
  
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def set_activity_user(user = current_user)
    Thread.current[:activity_user] = user
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end
  
  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      respond_to do |format|
        format.html { redirect_to login_url }
      end
      return false
    end
  end

  def themed(template_name)
    "layouts/themes/#{current_theme}/#{template_name}"
  end

  def try_translation(snippets = [], options = {})
    options[:default] = ''
    snippets.each do |s| 
      val = I18n.t(s, options).presence
      return val if val
    end
    nil
  end
  alias tt try_translation

end
