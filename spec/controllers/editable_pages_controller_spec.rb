require 'rails_helper'

RSpec.describe EditablePagesController, type: :controller do
  let!(:entity) { create :editable_page }
  let(:required_roles) { [:chief_editor] }
  let(:valid_create_params) { { editable_page: attributes_for(:editable_page) } }
  let(:valid_update_params) { { id: entity.id, editable_page: { body: 'changed' } } }
  let(:invalid_create_params) { { editable_page: { name: ' ' } } }
  let(:invalid_update_params) { { id: entity.id, editable_page: { name: ' ' } } }
  let(:path_after_create) { admin_editable_page_path(id: entity.class.last.id) }
  let(:path_after_update) { admin_editable_page_path(id: entity.id) }
  let(:path_after_destroy) { admin_editable_pages_path }

  it_behaves_like 'new_entity_with_required_roles'
  it_behaves_like 'create_entity_with_required_roles'
  it_behaves_like 'edit_entity_with_required_roles'
  it_behaves_like 'update_entity_with_required_roles'
  it_behaves_like 'destroy_entity_with_required_roles'
end