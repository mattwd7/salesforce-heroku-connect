require 'rails_helper'

describe SfCreateService do
  let(:expected_create_args) do
    {
      Name: post_title,
      external_id__c: post_external_id
    }
  end
  let(:post) do
    Post.skip_callback(:create, :after, :create_in_salesforce, raise: false)
    Post.create(
      title: post_title,
      content: post_content,
      user: User.create(first_name: 'Matt', last_name: 'Mystery')
    )
  end
  let(:post_title) { 'The title of my post' }
  let(:post_content) { 'The content or BODY of my post.' }
  let(:post_external_id) { post.external_id }
  let(:sobject_table_name) { 'Post__c' }
  let(:sobject_id) { 'imanidreturnedbysalesforce' }

  let(:sf_client) { instance_double('sf_client', 'create!' => sobject_id).as_null_object }

  before do
    allow(Restforce).to receive(:new).and_return(sf_client)
  end

  it 'sends created resource attributes to the corresponding salesforce table' do
    described_class.call(post)
    expect(sf_client).to have_received(:create!).with(sobject_table_name, **expected_create_args)
  end

  it 'updates resource with the returned salesforce_id' do
    described_class.call(post)
    expect(post.salesforce_id).to eq(sobject_id)
  end

  it 'does not call update to salesforce after updating sf_id' do
    described_class.call(post)
    expect(sf_client).not_to have_received(:upsert!)
  end
end

class DummyModel < ApplicationRecord
  # refactor to use this abstract instead of Post
end
