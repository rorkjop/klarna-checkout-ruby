require 'rspec/expectations'

RSpec::Matchers.define :have_attribute do |attr_name| # , type|
  match do |subject|
    attr_name = attr_name.to_s

    subject.should respond_to("#{attr_name}")
    subject.should respond_to("#{attr_name}=")

    # case type
    # when :readonly
    #   # expect { 
    #   subject.public_send("#{attr_name}=")
    #   # }.to raise_error(NoMethodError)
    # when :mandatory
    #   # subject.should validate_presence_of(attr_name)
    # when :optional
    #   # subject.should_not validate_presence_of(attr_name)
    # else
    #   raise "Please supply :readonly, :mandatory or :optional as second "+
    #         "argument to have_attribute matcher."
    # end

    # unless type == :readonly
    #   expect {
    #     subject.public_send("#{attr_name}=", 'new_value')  
    #   }.to change(subject, attr_name).to('new_value')
    # end
  end

  # failure_message_for_should do |klass|
  #   "expected #{klass.class.to_s} to have #{type.to_s} attribute #{attr_name}"
  # end
end
