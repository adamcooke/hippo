# frozen_string_literal: true

require 'hippo/recipe'

describe Hippo::Recipe do
  context '#repository' do
    it 'should return the path to the repository' do
      recipe = Hippo::Recipe.new('repository' => { 'url' => 'git@github.com:adamcooke/hippo' })
      expect(recipe.repository).to be_a Hippo::Repository
      expect(recipe.repository.url).to eq 'git@github.com:adamcooke/hippo'
    end
  end

  context '#build_specs' do
    it 'should provide a hash of build specs' do
      recipe = Hippo::Recipe.new('builds' => {
                                   'app' => {
                                     'dockerfile' => 'Dockerfile.test',
                                     'image-name' => 'adamcooke/app-test'
                                   }
                                 })
      expect(recipe.build_specs).to be_a Hash
      expect(recipe.build_specs['app']).to be_a Hippo::BuildSpec
      expect(recipe.build_specs['app'].dockerfile).to eq 'Dockerfile.test'
      expect(recipe.build_specs['app'].image_name).to eq 'adamcooke/app-test'
    end
  end
end
