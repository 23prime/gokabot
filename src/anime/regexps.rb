module Anime
  ANIME_OF = /(のアニメ|)$/
  RECOMMEND = /(おすすめ|オススメ)$/
  DAY_ANIME_OF = /曜(日|)#{ANIME_OF}/
  DAY = /(day|)$/i
  WEEK = /^Sun$|^Mon$|^Tue$|^Wed$|^Thu$|^Fri$|^Sat$/
  WEEK_RCM = /^sun$|^mon$|^tue$|^wed$|^thu$|^fri$|^sat$/
end
