cd("C:/Users/bence.komarniczky/Documents/Local_Projects/ICOM Hackathon/julia")
using Benchmarks

# read in all the words
all_words_dictionary = Set{UTF8String}(readdlm("all_words.txt", UTF8String))

alphabet = "abcdefghijklmnopqrstuvwxyz"

# read in tweets
all_tweets = open("data\\sample_texts.txt") do filehandle
  readlines(filehandle)
end



function edits1(word::UTF8String)
  word = lowercase(word)

  splits = [(word[1:i], i == length(word) ? "" : word[i+1:end]) for i in 0:length(word)]
  deletes = [join([word[1:i-1], word[i+1:end]]) for i in 1:length(word)]
  transposes = [join([a, b[2], b[1], b[3:end]]) for (a,b) in filter(x -> length(x[2]) > 1, splits)]

  replaces = Array{UTF8String}(length(splits) * length(alphabet))
  inserts = Array{UTF8String}(length(splits) * length(alphabet))

  for letter_i in 1:26
    for splitting_i in 1:length(splits)
      replaces[length(splits) *
      (letter_i - 1) + splitting_i] = join(
      [splits[splitting_i][1][1:end],
      alphabet[letter_i],
      splits[splitting_i][2][2:end]])

      inserts[length(splits) *
      (letter_i - 1) + splitting_i] = join(
      [splits[splitting_i][1][1:end],
      alphabet[letter_i],
      splits[splitting_i][2][1:end]])
    end
  end

  full_set = union(deletes, transposes, replaces, inserts)

  return Set{UTF8String}(full_set)
end


function known(words::Set{UTF8String}, all_words_set::Set{UTF8String})
  return intersect(words, all_words_set)
end

function correct(word::UTF8String, all_words_set::Set{UTF8String})
  candidates = known(edits1(word), all_words_set)

  # return word if valid
  word in candidates && return word::UTF8String

  final_candidate = word
  distance = Inf

  for candidate in candidates
    new_distance = leven(word, candidate)

    if new_distance < distance
      distance = new_distance
      final_candidate = candidate
    end
  end

  return final_candidate::UTF8String
end

function leven(s::UTF8String, t::UTF8String)

    length(s) == 0 && return length(t)::Int8;
    length(t) == 0 && return length(s)::Int8;

    s1 = s[2:end];
    t1 = t[2:end];

    return (s[1] == t[1]
        ? leven(s1, t1)
        : 1 + min(
                leven(s1, t1),
                leven(s,  t1),
                leven(s1,  t)
              )
    );
end


@benchmark correct(UTF8String("test"), all_words_dictionary)
# ================ Benchmark Results ========================
#      Time per evaluation: 13.78 ms [10.07 ms, 17.49 ms]
# Proportion of time in GC: 1.29% [0.00%, 5.85%]
#         Memory allocated: 723.90 kb
#    Number of allocations: 15755 allocations
#        Number of samples: 100
#    Number of evaluations: 100
#  Time spent benchmarking: 1.90 s
