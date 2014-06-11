namespace :forms do
  desc "Clear out all forms and responses and create a sample form with all fields"
  task :init do
    Form.destroy_all
    FormField.destroy_all
    FormResponse.destroy_all
    FormFieldResponse.destroy_all

    User.destroy_all
    user = FactoryGirl.create(:user, username: 'user1', active: true, staff: true,
                              password: 'password123', password_confirmation: 'password123')
    form = FactoryGirl.create(:form, number: 1, version: 1, user: user, current: true)
    %w(info address short_answer long_answer single_choice multiple_choice).each do |name|
      FactoryGirl.create("#{name}_field".to_sym, form: form)
    end
  end
end
