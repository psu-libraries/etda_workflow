class RedirectToWebaccessFailure < Devise::FailureApp
  def redirect_url
    # Webaccess.new.login_url + (request.env["ORIGINAL_FULLPATH"].blank? ? '' : request.env["ORIGINAL_FULLPATH"])
    'http://psu.edu'
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end

  # Overriding, so that we don't set the flash[:alert] with the unauthenticated message
  def redirect
    store_location!
    if flash[:timedout] && flash[:alert]
      flash.keep(:timedout)
      flash.keep(:alert)
    end
    redirect_to redirect_url
  end
end
