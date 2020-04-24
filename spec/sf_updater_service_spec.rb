require 'rails_helper'

describe SfUpdaterService do
  let(:sf_table_name) { 'Post__c' }
  let(:salesforce_id) { 'somethingfromsalesforce' }
  let(:new_post_title) { 'My new post title' }
  let(:expected_attributes) do
    {
      Name: new_post_title
    }
  end
  let(:post) do
    Post.skip_callback(:create, :after, :create_in_salesforce, raise: false)
    Post.skip_callback(:update, :before, :initialize_sf_updater, raise: false)
    Post.skip_callback(:update, :after, :update_in_salesforce, raise: false)

    Post.create(
      title: 'Original title',
      content: 'doesnt matter',
      user: User.create(first_name: 'Matt', last_name: 'Mystery')
    )
  end

  let(:sf_client) { instance_double('sf_client').as_null_object }

  before do
    allow(Restforce).to receive(:new).and_return(sf_client)
  end

  it 'updates the corresponding resource in salesforce via Id' do
    post.update(title: new_post_title)
    described_class.new(post, ['title']).call

    expect(sf_client).to have_received(:upsert!).with(
      sf_table_name,
      Id: post.salesforce_id,
      **expected_attributes
    )
  end

  it 'does not update fields that were not updated in Rails' do
    post.update(title: new_post_title)
    described_class.new(post, ['title']).call

    expect(sf_client).to have_received(:upsert!)
    expect(sf_client).not_to have_received(:upsert!).with(:external_id__c)
  end
end
