class StaticPagesController < ApplicationController

  def main
    render layout: false
  end

  def subproject
    render layout: 'subproject'
  end

  def admin
    require_staff_or_admin
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
    render layout: false
  end

end
