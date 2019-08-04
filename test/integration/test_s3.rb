require 'awspec'
require 'aws-sdk-iam'
REGION = 'eu-west-1'
client = Aws::STS::Client.new(region: REGION)
account_id = client.get_caller_identity.account
owner     = "awsbilling+dataplatform-wl"
sqs       = "dp-datalake-test-bucket-0-notifications"

describe s3_bucket('dp-datalake-test-bucket-0') do
  it { should exist }
  its(:acl_owner) { should eq "#{owner}" }
  its(:acl_grants_count) { should eq 1 }
  it { should have_acl_grant(grantee: "#{owner}", permission: 'FULL_CONTROL') }
  it { should have_policy('{"Version":"2012-10-17","Id":"123","Statement":[{"Sid":"AllowRead","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::988339453305:role/user-cradu","arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::047625233815:user/netf"]},"Action":["s3:List*","s3:GetObject*"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-0/*","arn:aws:s3:::dp-datalake-test-bucket-0"]},{"Sid":"AllowWrite","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::988339453305:role/user-cradu","arn:aws:iam::047625233815:user/ursuad"]},"Action":["s3:RestoreObject","s3:PutObject*","s3:PutObject","s3:List*","s3:GetObject*","s3:DeleteObject*","s3:AbortMultipartUpload"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-0/*","arn:aws:s3:::dp-datalake-test-bucket-0"]},{"Sid":"RequireMFA","Effect":"Deny","Principal":"*","Action":"s3:*","Resource":"arn:aws:s3:::dp-datalake-test-bucket-0/*","Condition":{"BoolIfExists":{"aws:MultiFactorAuthPresent":"false"}}}]}') }
  it do
    should have_lifecycle_rule(
      id: 'dp-datalake-test-bucket-0-content',
      filter: { prefix: '/' },
      transitions: [{ days: 30, storage_class: 'STANDARD_IA' }, { days: 60, storage_class: 'GLACIER' }],
      status: 'Enabled'
    )
  end
end

describe s3_bucket('dp-datalake-test-bucket-1') do
  it { should exist }
  its(:acl_owner) { should eq "#{owner}" }
  its(:acl_grants_count) { should eq 1 }
  it { should have_acl_grant(grantee: "#{owner}", permission: 'FULL_CONTROL') }
  it { should have_policy('{"Version":"2012-10-17","Statement":[{"Sid":"AllowRead","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::988339453305:role/user-cradu","arn:aws:iam::047625233815:user/netf"]},"Action":["s3:List*","s3:GetObject*"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-1/*","arn:aws:s3:::dp-datalake-test-bucket-1"]},{"Sid":"AllowWrite","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::988339453305:role/user-cradu"]},"Action":["s3:RestoreObject","s3:PutObject*","s3:PutObject","s3:List*","s3:GetObject*","s3:DeleteObject*","s3:AbortMultipartUpload"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-1/*","arn:aws:s3:::dp-datalake-test-bucket-1"]}]}') }
  it do
    should have_lifecycle_rule(
      id: 'dp-datalake-test-bucket-1-content',
      filter: { prefix: '/' },
      transitions: [{ days: 30, storage_class: 'STANDARD_IA' }, { days: 60, storage_class: 'GLACIER' }],
      status: 'Enabled'
    )
  end
end

describe s3_bucket('dp-datalake-test-bucket-2') do
  it { should exist }
  its(:acl_owner) { should eq "#{owner}" }
  its(:acl_grants_count) { should eq 1 }
  it { should have_acl_grant(grantee: "#{owner}", permission: 'FULL_CONTROL') }
  it { should have_policy('{"Version":"2012-10-17","Statement":[{"Sid":"AllowRead","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::047625233815:user/netf","arn:aws:iam::988339453305:role/user-cradu"]},"Action":["s3:List*","s3:GetObject*"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-2/*","arn:aws:s3:::dp-datalake-test-bucket-2"]},{"Sid":"AllowWrite","Effect":"Allow","Principal":{"AWS":["arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::988339453305:role/user-cradu"]},"Action":["s3:RestoreObject","s3:PutObject*","s3:PutObject","s3:List*","s3:GetObject*","s3:DeleteObject*","s3:AbortMultipartUpload"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-2/*","arn:aws:s3:::dp-datalake-test-bucket-2"]},{"Sid":"DenyWrite","Effect":"Deny","Principal":{"AWS":["arn:aws:iam::047625233815:user/ursuad","arn:aws:iam::988339453305:role/user-cradu"]},"Action":["s3:PutObject*","s3:PutObject"],"Resource":["arn:aws:s3:::dp-datalake-test-bucket-2/*","arn:aws:s3:::dp-datalake-test-bucket-2"],"Condition":{"StringNotEquals":{"s3:x-amz-acl":"bucket-owner-full-control"}}}]}') }
end

describe sqs("#{sqs}") do
  it { should exist }
  its(:queue_url) { should eq "https://sqs.eu-west-1.amazonaws.com/#{account_id}/#{sqs}" }
  its(:queue_arn) { should eq "arn:aws:sqs:eu-west-1:#{account_id}:#{sqs}" }
  its(:visibility_timeout) { should eq '30' }
end