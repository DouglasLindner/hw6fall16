require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'search_tmdb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      fake_results = [double('movie1'), double('movie2')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'should make the TMDb search terms available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:search_terms)).to eq('Ted')
    end 
    it 'should notify user of invalid search terms (blank)' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms=>''}
      expect(flash[:notice]).to eq("Invalid search term")
    end 
    it 'should select the index template for rendering when there are invalid search terms' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to(movies_path)
    end  
    it 'should notify user of no match for search terms' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms=>'Ted'}
      expect(flash[:notice]).to eq("No matching movies were found on TMDb")
    end 
    it 'should select the index template for rendering when there is no match for search terms' do
      fake_results = []
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to redirect_to(movies_path)
    end  
  end
  
  describe 'add_tmdb'
    it 'should call the model method that performs TMDb add once with once entries' do
      selectedIndexes = {double('id1') => 1}
      expect(Movie).to receive(:create_from_tmdb).once
      post :add_tmdb, {:tmdb_movies => selectedIndexes}
    end
    it 'should call the model method that performs TMDb add multiple times with multiple entries' do
      selectedIndexes = {double('id1') => 1, double('id2') => 1}
      expect(Movie).to receive(:create_from_tmdb).twice
      post :add_tmdb, {:tmdb_movies => selectedIndexes}
    end
    it 'should select the index template for rendering when checkboxes are checked' do
      selectedIndexes = {double('id1') => 1}
      allow(Movie).to receive(:create_from_tmdb).once
      post :add_tmdb, {:tmdb_movies => selectedIndexes}
      expect(response).to redirect_to(movies_path)
    end 
    it 'should notify user of "Movies successfully added to Rotten Potatoes" when checkboxes are checkeds' do
      selectedIndexes = {double('id1') => 1}
      allow(Movie).to receive(:create_from_tmdb).once
      post :add_tmdb, {:tmdb_movies => selectedIndexes}
      expect(flash[:notice]).to eq("Movies successfully added to Rotten Potatoes")
    end 
    it 'should select the index template for rendering when no checkboxes are checked' do
      allow(Movie).to receive(:create_from_tmdb).once
      post :add_tmdb, {:tmdb_movies => nil}
      expect(response).to redirect_to(movies_path)
    end 
    it 'should notify user "No movies selected" when no checkboxes are checked' do
      allow(Movie).to receive(:create_from_tmdb)
      post :add_tmdb, {:tmdb_movies => nil}
      expect(flash[:notice]).to eq("No movies selected")
    end

end
