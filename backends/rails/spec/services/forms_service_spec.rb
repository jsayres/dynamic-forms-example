require 'spec_helper'

describe FormsService do

  describe "::current_forms" do
    context "when there are current forms" do
      it "should return a list of the forms" do
        create(:form, current: true)
        expect(subject.current_forms.length).to eq 1
      end

      it "should attach a prev_published method onto each form" do
        create(:form, number: 1, version: 1, published: true)
        create(:form, number: 1, version: 2, current: true)
        create(:form, number: 2, version: 1, current: true)
        forms = subject.current_forms
        expect(forms[0].prev_published).to be true
        expect(forms[1].prev_published).to be false
      end

      it "should attach a num_responses method onto each form" do
        create(:form, number: 1, version: 1, current: true) do |f|
          f.responses << build(:form_response)
          f.responses << build(:form_response)
        end
        expect(subject.current_forms[0].num_responses).to eq 2
      end
    end

    context "when there are no current forms" do
      it "should return an empty list" do
        create(:form)
        expect(subject.current_forms.length).to eq 0
      end
    end
  end

  describe "::create" do
    let(:user) { create(:user) }

    context "when the form number is unspecified" do
      it "should create and return a form with the next highest number" do
        attrs = attributes_for(:form, number: nil, version: nil).merge(user: user)
        expect { subject.create(attrs) }.to change { Form.count }.by(1)
        form = Form.last
        expect(form.number).to eq 1
        expect(form.version).to eq 1
      end
    end

    context "when the form number is specified" do
      it "should create and return a form with the next highest version" do
        attrs = attributes_for(:form, number: 2, version: nil).merge(user: user)
        expect { subject.create(attrs) }.to change { Form.count }.by(1)
        form = Form.last
        expect(form.number).to eq 2
        expect(form.version).to eq 1
      end
    end

    it "should set the created form to be current and other versions old" do
      old_form = create(:form, number: 2, version: 1, current: true)
      attrs = attributes_for(:form, number: 2).merge(user: user)
      form = subject.create(attrs)
      expect(form.current).to be true
      expect(old_form.reload.current).to be false
    end

    it "should create any specified fields" do
      attrs = attributes_for(:form, number: nil, version: nil)
        .merge(user: user, fields: [attributes_for(:info_field)])
      subject.create(attrs)
      expect(FormField.last.kind).to eq 'info'
    end

    context "with invalid params" do
      it "should raise ActiveRecord::RecordInvalid" do
        attrs = attributes_for(:form)
        expect { subject.create(attrs) }.to(
          raise_exception(ActiveRecord::RecordInvalid)
        )
      end
    end
  end

  describe "::versions" do
    it "should return a list of forms with the specified number" do
      create(:form, number: 1, version: 1)
      create(:form, number: 1, version: 2)
      create(:form, number: 2, version: 1)
      versions = subject.versions(1)
      expect(versions.length).to eq 2
      expect(versions.map(&:version)).to eq [1, 2]
    end

    it "should raise ActiveRecord::RecordNotFound if form number doesn't exist" do
      expect { subject.versions(1) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end
  end

  describe "::version" do
    it "should return a form with the specified number and version" do
      create(:form, number: 3, version: 2)
      version = subject.version(3, 2)
      expect(version.number).to eq 3
      expect(version.version).to eq 2
    end

    it "should raise ActiveRecord::RecordNotFound if form doesn't exist" do
      expect { subject.version(3, 2) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end
  end

  describe "::update" do
    it "should reject the update if the form is locked" do
      create(:form, number: 3, version: 2, name: 'old name', locked: true)
      expect { subject.update(3, 2, name: 'new name') }.to(
        raise_exception(Form::Locked)
      )
    end

    it "should update the form information and return the form" do
      create(:form, number: 3, version: 2, name: 'old name')
      form = subject.update(3, 2, name: 'new name')
      expect(form.name).to eq 'new name'
    end

    it "should destroy any older fields and create any new ones" do
      create(:form, number: 3, version: 2, fields: [build(:info_field)])
      form = subject.update(3, 2, fields: [kind: 'short-answer', details: {}])
      expect(FormField.exists?(kind: 'info')).to be false
      expect(FormField.last.kind).to eq 'short-answer'
    end

    it "should raise ActiveRecord::RecordNotFound if the form doesn't exist" do
      expect { subject.update(3, 2, {}) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end

    it "should raise ActiveRecord::RecordInvalid if the new params are invalid" do
      create(:form, number: 3, version: 2, name: 'old name')
      expect { subject.update(3, 2, name: '') }.to(
        raise_exception(ActiveRecord::RecordInvalid)
      )
    end
  end

  describe "::publish" do
    it "should publish the specified form version and unpublish all other versions" do
      create(:form, number: 3, version: 1, published: true)
      create(:form, number: 3, version: 2)
      subject.publish(3, 2)
      expect(Form.all.pluck(:published)).to eq [false, true]
    end

    it "should mark the published form as locked" do
      form = create(:form, number: 3, version: 2)
      subject.publish(3, 2)
      expect(form.reload.locked).to be true
    end

    it "should raise ActiveRecord::RecordNotFound if the form doesn't exist" do
      expect { subject.publish(3, 2) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end

    it "should set a unique slug on the form" do
      form1 = create(:form, number: 1, version: 1, name: 'Test Form')
      form2 = create(:form, number: 2, version: 1, name: 'Test Form')
      subject.publish(1, 1)
      subject.publish(2, 1)
      expect(form1.reload.slug).to eq 'test-form'
      expect(form2.reload.slug).to eq 'test-form-1'
    end
  end

  describe "::unpublish" do
    it "should unpublish the specified form version" do
      create(:form, number: 3, version: 2, published: true)
      subject.unpublish(3, 2)
      expect(Form.last.published).to be false
    end

    it "should raise ActiveRecord::RecordNotFound if the form doesn't exist" do
      expect { subject.unpublish(3, 2) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end

    it "should clear the slug on the form" do
      form = create(:form, number: 1, version: 1, name: 'Test Form', slug: 'test-form')
      subject.unpublish(1, 1)
      expect(form.reload.slug).to eq ''
    end
  end

  describe "::form_with_responses" do
    it "should return a form with the responses and fields loaded" do
      f = create(:form, number: 1, version: 1)
      fld = f.fields.create(attributes_for(:short_answer_field))
      ['One', 'Two'].each do |answer|
        r = f.responses.create
        r.field_responses.create(form_field: fld, details: {answer: answer})
      end
      form = subject.form_with_responses(1, 1)
      expect(form.number).to eq 1
      expect(form.version).to eq 1
      answers = form.responses.map { |r| r.field_responses[0][:details][:answer] }
      expect(answers).to eq ['One', 'Two']
    end

    it "should return a form with an empty reponses list if there are no responses" do
      create(:form, number: 1, version: 1)
      expect(subject.form_with_responses(1, 1).responses).to eq []
    end

    it "should raise ActiveRecord::RecordNotFound if the form doesn't exist" do
      expect { subject.form_with_responses(1, 1) }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end
  end

  describe "::published_form" do
    it "should return the published form with the specified project and slug" do
      form = create(:form, published: true)
      published_form = subject.published_form(form.project, form.slug)
      expect(published_form.id).to eq form.id
    end

    it "should raise ActiveRecord::RecordNotFound if the form doesn't exist" do
      expect { subject.published_form('abc', '123') }.to(
        raise_exception(ActiveRecord::RecordNotFound)
      )
    end
  end

  describe "::published_forms" do
    it "should return a list of published forms for the specified project" do
      projects = PROJECTS.keys
      form1 = create(:form, number: 1, project: projects[0], published: true)
      form2 = create(:form, number: 2, project: projects[1], published: true)
      form3 = create(:form, number: 3, project: projects[0], published: false)
      form4 = create(:form, number: 4, project: projects[0], published: true)
      forms = subject.published_forms(projects[0])
      expect(forms.length).to eq 2
      expect(forms[0]).to eq form1
      expect(forms[1]).to eq form4
    end
  end

  describe "::build_response" do
    it "should build a response from a form and supplied attributes" do
      form = build(:form) do |f|
        [:info_field, :short_answer_field, :long_answer_field, :single_choice_field,
         :multiple_choice_field, :address_field].each_with_index do |fld, i|
          f.fields.build(attributes_for(fld, id: i + 1))
        end
      end
      field_response_attrs = {
        '1' => {answer: 'none'},
        '2' => {answer: 'short-answer'},
        '3' => {answer: 'long-answer'},
        '4' => {answer: 'A'},
        '5' => {answers: [{label: 'B', selected: true}]},
        '6' => {addressLine1: '1', addressLine2: '2', city: 'c', state: 's', zip: 'z'}
      }
      form_response = subject.build_response(form, field_response_attrs)
      (0..4).each do |n|
        expect(form_response.field_responses[n].details).to eq(
          field_response_attrs[(n + 2).to_s]
        )
      end
    end

    it "should set the user if supplied" do
      form = build(:form)
      user = build(:user)
      form_response = subject.build_response(form, {}, user)
      expect(form_response.user).to eq user
    end
  end

  describe "::create_response" do
    it "should create a response from a form and supplied attributes" do
      form = create(:form) do |f|
        [:info_field, :short_answer_field, :long_answer_field, :single_choice_field,
         :multiple_choice_field, :address_field].each_with_index do |fld, i|
          f.fields.create(attributes_for(fld, id: i + 1))
        end
      end
      field_response_attrs = {
        '1' => {answer: 'none'},
        '2' => {answer: 'short-answer'},
        '3' => {answer: 'long-answer'},
        '4' => {answer: 'A'},
        '5' => {answers: [{label: 'B', selected: true}]},
        '6' => {addressLine1: '1', addressLine2: '2',
                                   city: 'c', state: 's', zip: 'z'}
      }
      form_response = subject.create_response(form, field_response_attrs)
      (0..4).each do |n|
        expect(form_response.field_responses[n].details).to eq(
          field_response_attrs[(n + 2).to_s]
        )
      end
    end

    it "should set the user if supplied" do
      form = create(:form)
      user = create(:user)
      form_response = subject.create_response(form, {}, user)
      expect(form_response.user).to eq user
    end

    it "should raise ActiveRecord::RecordInvalid if the attributes are invalid" do
      form = create(:form) do |f|
        [:info_field, :short_answer_field, :long_answer_field, :single_choice_field,
         :multiple_choice_field, :address_field].each_with_index do |fld, i|
          f.fields.create(attributes_for(fld, id: i + 1))
        end
      end
      field_response_attrs = {}
      expect { subject.create_response(form, field_response_attrs) }.to(
        raise_exception(ActiveRecord::RecordInvalid)
      )
    end
  end

end
