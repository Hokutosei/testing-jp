# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include ExceptionNotifiable
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  
   rescue_from Exception do |e|
     if request.host =~ /localhost/ #20120123 fujikazu localhostのときはこれをskipする
       pp e.to_s
       pp e.backtrace
     else
       case e
       when ActionController::UnknownAction
         flash[:error] = e.message.to_s.split(".")[0]  rescue  "No action responded to #{params[:action]}"
       else
         return rescue_action_in_public(e)
       end
       # temp use
       render_404
     end
   end
   
end
