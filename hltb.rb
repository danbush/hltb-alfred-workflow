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

params = { :page => "1", :queryString => query, :t => "games", :sorthead => "popular", :sortd => "Normal%20Order", :plat => "", :length_type => "main", :length_min => "", :length_max => "", :detail => "" }

response =
  HTTParty.post("https://howlongtobeat.com/search_results?page=1",
  :headers => {
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:90.0) Gecko/20100101 Firefox/90.0",
      "Referer" => "https://howlongtobeat.com/"
  },    
  :body => params
  )

game_id = (response.scan(/id=(\d{4,5})/))

game_names = response.scan(/aria-label="([^"]*)"/)

game_difficulty_labels = response.scan(/<div class="search_list_tidbit text_white shadow_text">([^"]*)<\/div>/)

game_difficulties = response.scan(/<div class="search_list_tidbit center time_\d+">([^"]*)<\/div>/)

game_image = response.scan(/alt="Box Art" src="([^"]*)/)

if game_image[0] != nil
  game_image_1 = 'https://howlongtobeat.com' + game_image[0].join('')
  image_path_1 = "./images/" + game_names[0].to_s.downcase.sub('aria-label="', '').sub('["','').sub('"]','').sub(' ', '_') + ".jpg"
  open(image_path_1, 'wb') do |file|
    file << open(game_image_1).read
  end
end

if game_image[1] != nil
  game_image_2 = 'https://howlongtobeat.com' + game_image[1].join('')
  image_path_2 = "./images/" + game_names[1].to_s.downcase.sub('aria-label="', '').sub('["','').sub('"]','').sub(' ', '_') + ".jpg"
  open(image_path_2, 'wb') do |file|
    file << open(game_image_2).read
  end
end
if game_image[2] != nil
  game_image_3 = 'https://howlongtobeat.com' + game_image[2].join('')
  image_path_3 = "./images/" + game_names[2].to_s.downcase.sub('aria-label="', '').sub('["','').sub('"]','').sub(' ', '_') + ".jpg"
  open(image_path_3, 'wb') do |file|
    file << open(game_image_3).read
  end
end

if game_image[0] != nil
  difficulty_1 = game_difficulties[0].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_2 = game_difficulties[1].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_3 = game_difficulties[2].join('').sub("&#189;", ".5").sub("</div>\n</div> </div>\n", "").sub("</div>", "")
end

if game_image[1] != nil
  difficulty_4 = game_difficulties[3].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_5 = game_difficulties[4].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_6 = game_difficulties[5].join('').sub("&#189;", ".5").sub("</div>\n</div> </div>\n", "").sub("</div>", "")
end

if game_image[2] != nil
  difficulty_7 = game_difficulties[6].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_8 = game_difficulties[7].join('').sub("&#189;", ".5").sub("</div>", "")
  difficulty_9 = game_difficulties[8].join('').sub("&#189;", ".5").sub("</div>\n</div> </div>\n", "").sub("</div>", "")
end

if query == "update!"
  workflow.result
      .title("Hit enter to update the workflow")
      .subtitle("This will pull the latest version from git. Any modifications will be overwritten.")
      .arg("update!")
elsif game_names[0] != nil
  workflow.result
        .title(game_names[0].join(''))
        .subtitle(game_difficulty_labels[0].join('') + " - " + difficulty_1 + " | " + game_difficulty_labels[1].join('') + " - " + difficulty_2 + " | " + game_difficulty_labels[2].join('') + " - " + difficulty_3)
        .icon(image_path_1)
        .arg(game_id[0].join(''))
  if difficulty_4 != nil
    workflow.result
          .title(game_names[1].join(''))
          .subtitle(game_difficulty_labels[0].join('') + " - " + difficulty_4 + " | " + game_difficulty_labels[1].join('') + " - " + difficulty_5 + " | " + game_difficulty_labels[2].join('') + " - " + difficulty_6)
          .icon(image_path_2)
          .arg(game_id[1].join(''))
  end

  if difficulty_7 != nil
    workflow.result
          .title(game_names[2].join(''))
          .subtitle(game_difficulty_labels[0].join('') + " - " + difficulty_7 + " | " + game_difficulty_labels[1].join('') + " - " + difficulty_8 + " | " + game_difficulty_labels[2].join('') + " - " + difficulty_9)
          .icon(image_path_3)
          .arg(game_id[2].join(''))
  end
else
  workflow.result
        .title("Waiting for a game name...")
        .subtitle("Example: Doom")
        .arg(query)
end
print workflow.output
