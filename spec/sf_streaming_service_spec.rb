require 'rails_helper'

describe SfStreamingService do
  subject(:service) { described_class.new }

  let(:posts_channel_name) { 'AllPosts' }
  let(:users_channel_name) { 'AllUsers' }
  let(:salesforce_mappings) do
    {
      'Post' => {
        'sf_table_name' => 'Post__c',
        'sf_channel_name' => posts_channel_name,
        'field_mappings' => {
          'title' => 'Name',
          'external_id' => 'external_id__c'
        }
      },
      'User' => {
        'sf_table_name' => 'Contact',
        'sf_channel_name' => users_channel_name,
        'field_mappings' => {
          'first_name' => 'FirstName',
          'last_name' => 'LastName',
          'email' => 'email',
          'external_id' => 'external_id__c'
        }
      }
    }
  end
  let(:sf_client) { instance_double('sf_client').as_null_object }

  before do
    allow(Restforce).to receive(:new).and_return(sf_client)
    allow(service).to receive(:sf_mappings).and_return(salesforce_mappings)
  end

  it 'subscribes to the corresponding resource channel in Salesforce' do
    service.send(:establish_subscriptions)

    expect(sf_client)
      .to have_received(:subscription)
      .with(
        "/topic/#{posts_channel_name}",
        replay: -1
      )

    expect(sf_client)
      .to have_received(:subscription)
      .with(
        "/topic/#{users_channel_name}",
        replay: -1
      )
  end

  context 'with a topic that does not exist in SF' do
    let(:sf_client) do
      instance_double(
        'sf_client',
        query: double(
          'Restforce::Collection',
          pluck: ['AllPosts']
        )
      ).as_null_object
    end

    it 'logs a warning' do
      expect(Rails.logger).to receive(:warn)
      service.send(:establish_subscriptions)
    end
  end

  context 'after receiving a message from SF' do
    let(:field_mappings) { salesforce_mappings['Post']['field_mappings'] }
    let(:sobject) do
      {
        'Id' => 'a005w00000aV7R9AAK',
        'Name' => updated_title
      }
    end
    let(:updated_title) { 'My new post title' }

    it 'transforms data structure from SF to app model attributes' do
      expect(service.send(:sobject_to_attributes, sobject, field_mappings))
        .to eq(
          title: updated_title
        )
    end
  end
end
