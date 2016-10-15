class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      moviesArray = Tmdb::Movie.find(string)
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
    if(moviesArray != nil)
      moviesArray.collect do |current_movie| 
        ratingArray = Tmdb::Movie.releases(current_movie.id)["countries"].select {|info| info["iso_3166_1"] == "US"}
        if(ratingArray == [])
          {:title =>current_movie.title,:rating=>"",:tmdb_id=>current_movie.id,:release_date=>current_movie.release_date}
        else
          ratingArray.reject! {|x| x["certification"] == ""}
          if(ratingArray == [])
           {:title =>current_movie.title,:rating=>"",:tmdb_id=>current_movie.id,:release_date=>current_movie.release_date}
          else
            {:title =>current_movie.title,:rating=>ratingArray[0]["certification"],:tmdb_id=>current_movie.id,:release_date=>current_movie.release_date}
          end
        end
        #{:title =>current_movie.title,:rating=>Tmdb::Movie.releases(current_movie.id),:tmdb_id=>current_movie.id,:release_date=>current_movie.release_date}
      end
    else
      return []
    end
  end
  
  def self.create_from_tmdb(id)
    Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
    begin
      movie = Tmdb::Movie.detail(id)
      ratingArray = Tmdb::Movie.releases(id)["countries"].select {|info| info["iso_3166_1"] == "US"}
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
    rating = ""
    if(ratingArray == [])
      rating = ""
    else
      ratingArray.reject! {|x| x["certification"] == ""}
      if(ratingArray == [])
        rating = ""
      else
       rating = ratingArray[0]["certification"]
      end
    end
    movieAttributes = {:title=> movie["title"], :release_date=> movie["release_date"], :description=> movie["overview"], :rating=> rating}
    Movie.create!(movieAttributes)
  end
end
