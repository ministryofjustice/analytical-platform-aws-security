# frozen_string_literal: true

iam_user_name = 'kitchen@cooking.test.com'
iam_name = 'kitchen'

control 'iam_resources' do
  describe aws_iam_policy(policy_name: "enable-guardduty") do
    it { should exist }
  end
end
