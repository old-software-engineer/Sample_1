module ApplicationHelper
  def callIsValid(code_country)
    unless %w(1 33 343 44 91).include?("#{code_country}")
     return 'none'
    else
      return 'inline'
    end
  end

  def days_aging created_at
    Date.today.mjd - created_at.mjd
  end

  def user_avatar(user, options = {})
    image_tag user.avatar, options if user.avatar.present?
  end

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end
end
