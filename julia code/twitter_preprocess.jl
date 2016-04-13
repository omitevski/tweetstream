# all_tweets = open("data\\sample_texts.txt") do filehandle
#   readlines(filehandle)
# end

function tweet_prepare(tweet::AbstractString)
  # Different regex parts for smiley faces
	eyes = "[8:=;]"
	nose = "['`\-]?"

    tweet = replace(tweet, r"(\b[A-Z]){3,}\b", x -> "$(lowercase(x)) <ALLCAPS>")

    # split hashtags at capital letters
    for to_replace in matchall(r"#\S+", tweet)
      hashtag_body = to_replace[2:end]
      if uppercase(hashtag_body) == hashtag_body
        tweet = replace(tweet, to_replace, " <HASHTAG> $hashtag_body <ALLCAPS>")
      else
        tweet = replace(tweet, to_replace, " <HASHTAG> $(join(split(hashtag_body, r"(?=[A-Z])"), " "))")
      end
    end


		tweet = replace(tweet, r"https?:\/\/\S+\b|www\.(\w+\.)+\S*" ," <URL> ")
		tweet = replace(tweet, "/"," / ") # Force splitting words appended with slashes (once we tweet_prepared the URLs, of course)
		tweet = replace(tweet, r"@\w+", " <USER> ")
		tweet = replace(tweet, Regex("$eyes$nose[)d]+|[)d]+$nose$eyes"), " <SMILE> ")
	  tweet = replace(tweet, Regex("$eyes$(nose)p+"), " <LOLFACE> ")
		tweet = replace(tweet, Regex("$eyes$(nose)\\(+|\\)+$(nose)$(eyes)"), " <SADFACE> ")
		tweet = replace(tweet, Regex("$eyes$(nose)[\/|l*]"), " <NEUTRALFACE> ")
    tweet = replace(tweet, r"-,-", " <ANNOYEDFACE> ")
		tweet = replace(tweet, r"<3"," <HEART> ")
		tweet = replace(tweet, r"[^\D]?[-+.]?[\d]+[:,.\d]*[^\D]+", " <NUMBER> ")


    tweet = replace(tweet, r"([!?.]){2,}", x -> "$(x[1]) <REPEAT> ")

    tweet = replace(tweet, r"\b(\S*?)([a-zA-Z])\2{2,}\b", x -> "$x <ELONG> ")
    tweet = replace(tweet, r"\s{2,}", " ")

  return tweet::AbstractString
end

tweet_prepare("@george")
tweet_prepare(":)")
tweet_prepare(":(")
tweet_prepare(":|")
tweet_prepare("<3")
tweet_prepare("12")
tweet_prepare("http://twitter.com")
tweet_prepare("HELLO EVERYONE :( tweet with a #FridayFeeling!!!!)")

tweet = "#FridayFeeling this is not #ThisIs"



for (i, tweet) in enumerate(all_tweets[1:50])
  println("$i $(tweet)\n$(tweet_prepare(tweet)) \n")
end


@time [tweet_prepare(tweet) for tweet in all_tweets[1:100000]]
