#!/usr/bin/env ruby
$LOAD_PATH.unshift ("./gems/httparty-0.16.4/lib")
$LOAD_PATH.unshift ("./gems/multi_xml-0.6.0/lib")
$LOAD_PATH.unshift ("./gems/mime-types-3.2.2/lib")
$LOAD_PATH.unshift ("./gems/mime-types-data-3.2018.0812/lib")
$LOAD_PATH.unshift ("./gems/alfred-3_workflow-0.1.0/lib")

require 'httparty'
require 'alfred-3_workflow'

require 'open-uri'
require 'fileutils'

require 'json'

workflow = Alfred3::Workflow.new

query = ARGV[0]

FileUtils.rm_rf(Dir['./images/*'])

# Set some defaults
game_id = ""
game_names = ""
game_difficulties = ""
game_difficulty_labels = ""

difficulty_1 = ""
difficulty_2 = ""
difficulty_3 = ""

game_image_1 = ""
game_image_2 = ""
game_image_3 = ""

image_path_1 = ""
image_path_2 = ""
image_path_3 = ""

parsed_response = ""

response =
  HTTParty.post("https://howlongtobeat.com/api/search",
  :headers => {
      'Content-Type' => "application/json",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:90.0) Gecko/20100101 Firefox/90.0",
      "Referer" => "https://howlongtobeat.com/"
  },    
  :body => {"searchType":"games","searchTerms":["#{query}"],"searchPage":1,"size":20,"searchOptions":{"games":{"userId":0,"platform":"","sortCategory":"popular","rangeCategory":"main","rangeTime":{"min":0,"max":0},"gameplay":{"perspective":"","flow":"","genre":""},"modifier":""},"users":{"sortCategory":"postcount"},"filter":"","sort":0,"randomizer":0}}.to_json
  )
  
game_data = response["data"]

game_id = game_data.map { |h| h['game_id'] }.uniq

game_names = game_data.map { |h| h['game_name'] }

game_difficulty_labels = ["Main", "Main + Extra", "Completionist"]

game_difficulties_main = game_data.map { |h| h['comp_main'] }
game_difficulties_extra = game_data.map { |h| h['comp_plus'] }
game_difficulties_complete = game_data.map { |h| h['comp_100'] }

game_image = game_data.map { |h| h['game_image'] }

if game_image[0] != nil
  game_image_1 = 'https://howlongtobeat.com/games/' + game_image[0]
  image_path_1 = "./images/" + game_names[0].to_s.downcase + ".jpg"
  open(image_path_1, 'wb') do |file|
    file << open(game_image_1).read
  end
end

if game_image[1] != nil
  game_image_2 = 'https://howlongtobeat.com/games/' + game_image[1]
  image_path_2 = "./images/" + game_names[1].to_s.downcase + ".jpg"
  open(image_path_2, 'wb') do |file|
    file << open(game_image_2).read
  end
end
if game_image[2] != nil
  game_image_3 = 'https://howlongtobeat.com/games/' + game_image[2]
  image_path_3 = "./images/" + game_names[2].to_s.downcase + ".jpg"
  open(image_path_3, 'wb') do |file|
    file << open(game_image_3).read
  end
end

def difficulty_conversion(raw)
  raw_integer = raw.to_i
  final_integer = raw_integer/60/60
  return final_integer.to_s + " hours"
end

if game_image[0] != nil
  difficulty_1 = difficulty_conversion(game_difficulties_main[0])
  difficulty_2 = difficulty_conversion(game_difficulties_extra[0])
  difficulty_3 = difficulty_conversion(game_difficulties_complete[0])
end

if game_image[1] != nil
  difficulty_4 = difficulty_conversion(game_difficulties_main[1])
  difficulty_5 = difficulty_conversion(game_difficulties_extra[1])
  difficulty_6 = difficulty_conversion(game_difficulties_complete[1])
end

if game_image[2] != nil
  difficulty_7 = difficulty_conversion(game_difficulties_main[2])
  difficulty_8 = difficulty_conversion(game_difficulties_extra[2])
  difficulty_9 = difficulty_conversion(game_difficulties_complete[2])
end

if query == "update!"
  workflow.result
      .title("Hit enter to update the workflow")
      .subtitle("This will pull the latest version from git. Any modifications will be overwritten.")
      .arg("update!")
elsif game_names[0] != nil
  workflow.result
        .title(game_names[0])
        .subtitle(game_difficulty_labels[0] + " - " + difficulty_1 + " | " + game_difficulty_labels[1] + " - " + difficulty_2 + " | " + game_difficulty_labels[2] + " - " + difficulty_3)
        .icon(image_path_1)
        .arg(game_id[0])
  if difficulty_4 != nil
    workflow.result
          .title(game_names[1])
          .subtitle(game_difficulty_labels[0] + " - " + difficulty_4 + " | " + game_difficulty_labels[1] + " - " + difficulty_5 + " | " + game_difficulty_labels[2] + " - " + difficulty_6)
          .icon(image_path_2)
          .arg(game_id[1])
  end

  if difficulty_7 != nil
    workflow.result
          .title(game_names[2])
          .subtitle(game_difficulty_labels[0] + " - " + difficulty_7 + " | " + game_difficulty_labels[1] + " - " + difficulty_8 + " | " + game_difficulty_labels[2] + " - " + difficulty_9)
          .icon(image_path_3)
          .arg(game_id[2])
  end
else
  workflow.result
        .title("Waiting for a game name...")
        .subtitle("Example: Doom")
        .arg(query)
end
puts workflow.output