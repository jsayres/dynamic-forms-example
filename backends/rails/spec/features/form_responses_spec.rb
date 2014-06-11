require 'spec_helper'

describe "Form Response Pages" do

  subject { page }

  describe "project forms list page" do
    let(:p1) { PROJECTS.keys[0] }
    let(:p2) { PROJECTS.keys[1] }

    it "should display a list of published forms within the project" do
      f1 = create(:form, number: 1, name: "#{p1} form 1", project: p1, published: true)
      f2 = create(:form, number: 2, name: "#{p1} form 2", project: p1, published: true)
      f3 = create(:form, number: 3, name: "#{p2} form 3", project: p2, published: true)
      f4 = create(:form, number: 4, name: "#{p2} form 4", project: p2, published: true)
      visit project_forms_path(p1)
      expect(page).to have_content('Available Forms')
      expect(page).to have_selector('table tbody tr', count: 2)
      expect(page).to have_link("#{p1} form 1".titleize,
                                href: new_form_response_path(p1, f1.slug))
      expect(page).to have_link("#{p1} form 2".titleize,
                                href: new_form_response_path(p1, f2.slug))
    end

    it "should indicate when there are no forms" do
      visit project_forms_path(p1)
      expect(page).to have_content('Available Forms')
      expect(page).to have_selector('p.no-forms')
    end
  end

  describe "form render page" do
    let(:form) do
      create(:form, published: true) do |f|
        f.fields.create(kind: 'info', details: {text: 'Info text'})
        f.fields.create(kind: 'short-answer', details: {
          question: 'Short answer question', label: 'Answer', required: true
        })
        f.fields.create(kind: 'long-answer', details: {
          question: 'Long answer question', label: 'Answer', required: true
        })
        f.fields.create(kind: 'single-choice', details: {
          question: 'Single choice question', required: true, choices: [
            { label: "A" }, { label: "B" }, { label: "C" }
          ]
        })
        f.fields.create(kind: 'multiple-choice', details: {
          question: 'Multiple choice question', required: true, choices: [
            { label: "A" }, { label: "B" }, { label: "C" }
          ]
        })
        f.fields.create(kind: 'address', details: {
          question: 'Address question', required: true
        })
      end
    end
    let(:user) { create(:user) }

    it "should render the form and all fields" do
      visit new_form_response_path(form.project, form.slug)
      expect(page).to have_content('Info text')
      expect(page).to have_content('Short answer question')
      expect(page).to have_content('Long answer question')
      expect(page).to have_content('Single choice question')
      expect(page).to have_content('Multiple choice question')
      expect(page).to have_content('Address question')
    end

    context "when filled out with valid information" do
      it "should save the response and display a success message" do
        visit login_path
        fill_in "username", with: user.username
        fill_in "password", with: user.password
        click_on "login"
        visit new_form_response_path(form.project, form.slug)
        fill_in "responses[#{form.fields[1].id}][answer]", with: 'short answer response'
        fill_in "responses[#{form.fields[2].id}][answer]", with: 'long answer response'
        choose "B"
        check "A"
        check "C"
        fill_in "responses[#{form.fields[5].id}][addressLine1]", with: 'address line 1'
        fill_in "responses[#{form.fields[5].id}][addressLine2]", with: 'address line 2'
        fill_in "responses[#{form.fields[5].id}][city]", with: 'city'
        fill_in "responses[#{form.fields[5].id}][state]", with: 'state'
        fill_in "responses[#{form.fields[5].id}][zip]", with: '12345'
        click_on 'Submit'
        expect(page).to have_content('Thank you for filling out the form. It has been submitted successfully.')
      end
    end

    context "when filled out with invalid information" do
      it "should re-render the form and show appropriate error messages" do
        visit login_path
        fill_in "username", with: user.username
        fill_in "password", with: user.password
        click_on "login"
        visit new_form_response_path(form.project, form.slug)
        click_on 'Submit'
        expect(page).to have_content(form.fields[0].details[:text])
        (1..5).each do |n|
          expect(page).to have_content(form.fields[n].details[:question])
        end
        expect(page).to have_selector('small.error', count: 8)
      end
    end
  end

end
