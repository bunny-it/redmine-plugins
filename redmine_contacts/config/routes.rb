# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2010-2025 RedmineUP
# http://www.redmineup.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

#custom routes for this plugin
  resources :contacts, :path_names => {:contacts_notes => 'notes'} do
    collection do
      get :bulk_edit, :context_menu, :edit_mails, :contacts_notes
      post :bulk_edit, :bulk_update, :send_mails, :preview_email
      delete :bulk_destroy
    end
    member do
      get 'tabs/:tab' => 'contacts#show', :as => "tabs"
      get 'load_tab' => 'contacts#load_tab', :as => "load_tab"
    end
    resources :contacts_projects, :path => "projects", :only => [:new, :create, :destroy]
  end

  resources :projects do
    resources :contacts, :path_names => {:contacts_notes => 'notes'} do
      collection do
        get :contacts_notes
      end
    end
    resources :deal_categories

  end
  resources :deals do
    collection do
      get :bulk_edit, :context_menu, :edit_mails, :preview_email
      post :bulk_edit, :bulk_update, :send_mails, :update_form
      put :update_form
      delete :bulk_destroy
    end
    member do
      put :add_product, defaults: { format: :json }
    end
  end

  resources :projects do
    resources :deals, :only => [:new, :create, :index]
    resources :deal_categories, :only => [:new, :create, :index]
  end

  resources :deal_categories, :only => [:edit, :update, :destroy]

  resources :deal_statuses, :except => :show do
    collection do
      put :assign_to_project
    end
  end

  resources :projects do
    resources :crm_queries, :only => [:new, :create]
  end

  resources :crm_queries, :except => [:show]

  resources :notes

  match '/contacts_tags', :controller => 'contacts_tags', :action => 'destroy', :via => :delete

  resources :contacts_tags do
    collection do
      post :merge, :context_menucha
      get :context_menu, :merge
    end
  end
  if Redmine::VERSION.to_s >= '4.1'
    get   '/contacts/imports/new', :to => 'imports#new',
        :defaults => {:type => 'ContactImport'}, :as => 'new_contacts_import'

    get   '/deals/imports/new', :to => 'imports#new',
        :defaults => {:type => 'DealImport'}, :as => 'new_deals_import'
  end

  match 'contacts/:contact_id/duplicates' => 'contacts_duplicates#index', :via => [:get, :post]

  match 'projects/:project_id/deal_categories/new' => 'deal_categories#new', :via => [:get, :post]


  match 'auto_completes/taggable_tags' => 'auto_completes#taggable_tags', :via => :get, :as => 'auto_complete_taggable_tags'
  match 'auto_completes/contact_tags' => 'auto_completes#contact_tags', :via => :get, :as => 'auto_complete_contact_tags'
  match 'auto_completes/contacts' => 'auto_completes#contacts', :via => :get, :as => 'auto_complete_contacts'
  match 'auto_completes/companies' => 'auto_completes#companies', :via => :get, :as => 'auto_complete_companies'
  match 'auto_completes/deals' => 'auto_completes#deals', :via => :get, :as => 'auto_complete_deals'

  match 'users/new_from_contact/:id' => 'users#new_from_contact', :via => :get
  %w(index duplicates merge).each do |action|
    match "contacts_duplicates/#{action}", controller: 'contacts_duplicates', action: action, via: [:get, :post], as: "contacts_duplicates_#{action}"
  end
  match 'contacts_duplicates/search' => 'contacts_duplicates#search', :via => :get, :as => 'contacts_duplicates_search'
  %w(create_issue close).each do |action|
    match 'contacts_issues', controller: 'contacts_issues', action: action, via: [:get, :post, :delete, :put]
  end
  %w(load).each do |action|
    match 'contacts_vcf', controller: 'contacts_vcf', action: action, via: [:get, :post]
  end
  %w(add autocomplete delete search).each do |action|
    match "deal_contacts/#{action}", controller: 'deal_contacts', action: action, via: [:get, :post, :delete]
  end
  %w(new close).each do |action|
    match 'deals_tasks', controller: 'deals_tasks', action: action, via: [:get, :post, :put]
  end
  %w(save).each do |action|
    match 'contacts_settings', controller: 'contacts_settings', action: action, via: [:get, :post]
  end
  %w(index).each do |action|
    match 'contacts_mail_handler', controller: 'contacts_mail_handler', action: action, via: [:get, :post]
  end
  match 'attachments/contacts_thumbnail/:id(/:size)', :controller => 'attachments', :action => 'contacts_thumbnail', :id => /\d+/, :via => :get
