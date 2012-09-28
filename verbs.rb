class Verbs #class name upper case!!
end

def input
  print "Gib ein verb ein:"
  @input = gets.downcase.strip
  run_it
  
  require 'benchmark'
  puts "Benchmark: #{Benchmark.realtime { "a"*1_000_000 }} sec"
  return true
end

def run_it
  @input_wo_ending = create_stem
  found_verbs = iterate_db_search
  check_form(found_verbs)
  print print_analyzed_input
  print print_output
end

def create_stem
  @ending = find_ending
  @ending_string = @ending[3]
  stem = @input.clone
  stem.slice!(/#{@ending_string}$/)
  stem
end

def find_ending # endings sollten vielleicht sogar in einer priorit‰tenreihenfolge angeordnet sein. also t und nt zuerst...
  @endings = {
              /o$/ => ["1.Pers.", "Singular", "aktiv", "o"],
              /m$/ => ["1.Pers.", "Singular", "aktiv", "m"],#act endings[0] $ = \b
              /((?<=([aer])|([^tr]i)|([^aeirsl]ti)|([^aie]ri)|([sft]eri)|(quiri)|(quaeri)|([^c][a-z]peri)|([^a-z]geri)|([^a-z]pari)|([^a-z]meti)))s$/ => ["2.Pers.", "Singular", "aktiv", "s"],
              /(?<=[aei])t$/ => ["3.Pers.", "Singular", "aktiv", "t"], #alles auﬂer n davor?
              /mus$/ => ["1.Pers.", "Plural", "aktiv", "mus"],
              /(?<=[aei])tis$/ => ["2.Pers.", "Plural", "aktiv", "tis"], #s-problem!!!!
              /(?<=[aeiu])nt$/ => ["3.Pers.", "Plural", "aktiv", "nt"], #dont match perf3rdpl
              /re$/ => ["Infinitiv", "", "aktiv", "re"],
                        
              /(?<=[^t])i$/ => ["1.Pers.", "Singular", "aktiv", "i"], #perf. act. perf-stem end on t?
              /isti$/ => ["2.Pers.", "Singular", "aktiv", "istis"], #endings[2]
              /it$/ => ["3.Pers.", "Singular", "aktiv", "it"],
              /imus$/ => ["1.Pers.", "Plural", "aktiv", "imus"],
              /istis$/ => ["2.Pers.", "Plural", "aktiv", "istis"],
              /erunt$/ => ["3.Pers.", "Plural", "aktiv", "erunt"],
              /isse$/ => ["Infinitiv", "", "aktiv", "isse"],
                          
              /(or|(?<!u)r)$/ => ["1.Pers.", "Singular", "passiv", "r"], #passiv endings[3] old one /(?<!u)r$/ didn't match or endings!
              /((?<=([^p]a)|([^aefgtpsx]e)|([^(qu)]i)|([cr][uia]pe)|([a-z][tg]e)))ris$/ => ["2.Pers.", "Singular", "passiv", "ris"],
              /(?<=[aei])tur$/ => ["3.Pers.", "Singular", "passiv", "tur"],
              /mur$/ => ["1.Pers.", "Plural", "passiv", "mur"],
              /mini$/ => ["2.Pers.", "Plural", "passiv", "mini"],
              /ntur$/ => ["3.Pers.", "Plural", "passiv", "ntur"],
              /(ri|(?<!n)i)$/ => ["Infinitiv", "", "passiv", "ri", "i"]
              # /ri$/ => ["Infinitiv", "", "passiv", "ri"],
               #/(?<!n)i$/ => ["Infinitiv", "", "passiv", "i"] #alles auﬂer n-vor i. gibt es einen n-stamm?
              }
            
  personal_ending = @endings.keys
  ending = personal_ending.select { |x| @input.match(x) }
  @endings[ending[0]]
end

def iterate_db_search
  found_verbs = {}
  stem = @input_wo_ending.clone
  
  case
  when @input_wo_ending.match(/e$/)
    found_verbs[stem] = look_up_stem(stem)
    stem.chop! << "a"
  when @input_wo_ending.match(/[^aeiou]$/)
    stem << "a"
  end

  until stem == ""
    found_verbs[stem] = look_up_stem(stem) #interessantes zum clone verhalten hier.
    stem.chop!
  end
  found_verbs.delete_if {|key, val| val == {} }
end

def look_up_stem(stem)
  require 'yaml'
  db = File.open("verbs_db.yaml", "r") do |file|
    YAML.load(file)
  end

  db.select { |key, val| val.include? (stem) }
end

def check_form(found_verbs) # hier erst tempuszeichen checken?
  @found_stem = found_verbs.keys[0]
  conj = found_verbs[@found_stem].values[0][0] # almost a hack! check doc why
  
  if conj == "1" && @input_wo_ending.match(/e$/)
    signs = nil
    @binding_voc = "e"
    # hier kˆnnte man das a von ama lˆschen
  elsif conj == "1" && @ending[0] == "1.Pers." && @input_wo_ending.match(/[^e]$/)
    signs = nil
    # hier kˆnnte man das a von ama lˆschen
  else
    signs = @input_wo_ending[@found_stem.length..-1] # !! < > Vergleich, wegen aKonj! :
  end
  
  check_for_signs(signs, conj)
end

def check_for_signs(signs, conj)
  case
  when conj.match(/[35]$/) && signs.match(/^i/)
    @binding_voc = "i"
   when conj.match(/[345]$/) && signs.match(/^u/)
    @binding_voc = "u"
   end
  
  if signs != nil && signs.match(/ba/)
    @tempus_sign = "ba"
  else

  end
 
  if signs != nil && signs.match(/a#{@ending_string}/)
    @tempus_sign = "a"
  end

  if signs != nil && signs.match(/re$/)
    @tempus_sign = "re"
  end

  unless @tempus_sign == nil
  if @tempus_sign.match(/^[^aeiou]/) && conj.match("3")
    @binding_voc = "e"
  end

  if @tempus_sign.match("ba") && conj.match("4")
    @binding_voc = "e"
  end

  if @tempus_sign.match("ba") && conj.match("5")
    @binding_voc = "i - e"
  end
  end

end

def print_analyzed_input
  analyzed_input = [@found_stem, @binding_voc, @tempus_sign, @ending_string]
  printer = analyzed_input.reject {|x| x == nil}.join(" - ") + "\n"
  puts
  @binding_voc = nil
  @tempus_sign = nil
  printer
end

def print_output
  persona = @ending[0]
  numerus = @ending[1]
  genus = @ending[2]
  output = [persona, numerus, genus]
  output.join(", ") + "\n"
end

if __FILE__ == $PROGRAM_NAME
  while input
  end
end