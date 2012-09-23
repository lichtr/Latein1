#Verbenerkennung
def input
  print "\nGib ein Verb ein! \n \n"
  gets.downcase.strip                   #input
end


def define_verb (verb)
    endings = [
             [ "o#{/$/}",              #act endings[0] $ = \b
               "#{/(?<=[^rt][aei])/}s#{/\b/}", # does not match mittis! r-stems?
               "#{/(?<=[aei])/}t#{/\b/}",    #alles außer n davor?
               "mus#{/\b/}",
               "#{/(?<=[aei])/}tis#{/\b/}", #s-problem!!!!
               "nt#{/\b/}",
               "re#{/\b/}"
              ],
                     
             [ "#{/[aeu]/}m#{/\b/}"              #2nd: 1.P. act endings[1]
              ],
             
             [ "#{/(?<=[aeo])/}r#{/\b/}",             #passiv endings[2]
               "#{/(?<=[aei])/}ris#{/\b/}",
               "#{/(?<=[aei])/}tur#{/\b/}",
               "mur#{/\b/}",
               "mini#{/\b/}",
               "ntur#{/\b/}",
               "ri#{/\b/}",
               "#{/(?<=[a-mo-z])/}i#{/\b/}"                #alles außer n-vor i. gibt es einen n-stamm?
              ]
            ]  
  
 
 
  def test_ending (verb, endings) 
    for j in 0..endings.length-1                        #j = aktive oder passive Endungen? for-SChleife lässt Array durchlaufen
      for i in 0..endings[j].length-1                   #i = durchprobieren der personen
        if verb.match("#{endings[j][i]}")
          ending = verb.match("#{endings[j][i]}")
          return j, i #ending
        end
      end
    end
  end
  var = test_ending verb, endings
  j = var[0]
  i = var[1]
  ending = endings[var[0]][var[1]] #no need of i, j; sometimes.
  
  
  def stem (verb, ending) #s, j, i)   #Warum geht das da nicht als eigene def?
    #ending_new = ending.clone
    #ending_new.to_s
    ending = verb.match("#{ending}").to_s #("#{endings[j][i]}").to_s       #check ending     
    stem_vow = verb.clone            # stamm definieren = endung abhacken, nach länge der endung #gernot
    length = ending.length
    length.times do stem_vow.chop!
    end
    if stem_vow.match("b#{/[aeiu]\b/}")        #reduce ba-Imperfekt and bi,be,bu-Future
      stem_vow.chop!.chop!
    elsif stem_vow.match("b#{/\b/}")            #reduce Future b-1stPsg
      stem_vow.chop!
    end  
    stem = stem_vow.chop                  #reduced by vowel
  end
  stem = stem verb, ending #s, j, i 
       
       
  def search_file (stem)
    f = File.read('stems2.txt')
    f.lines.grep(/(\A#{stem}.?)/) do |x| y = "#{f.lines.find_index(x)+1}  #{x}"
    end
  end
  forms = search_file stem # array 0 = line number, 1 = present stem, 2 = perf stem
       
       
  def konjugation (forms) 
    if forms.length == 0 # if nothin is found reduce stem a second time: faciet = faci; nothing to be found unless it's chopped once more
      print "Leider nicht im Stammverzeichnis \n"
      konjugation = " "
    else
      line = forms[0].to_i
      case line
        when 1..7 then konjugation = "A-Konjugation" #find out range automatically?
        when 9..12 then konjugation = "E-Konjugation"
        when 14..21 then konjugation = "konsonantische Konjugation"
        when 23..26 then konjugation = "I-Konjugation"
        when 28..32 then konjugation = "I-Konjugation"
      end 
    end 
  end
  konjugation = konjugation forms
  
  
  def pers_numerus (i)
    case i  #sg or pl and pers
      when 0..2 then pers_numerus = "#{i + 1}.Person Singular"
      when 3..5 then pers_numerus = "#{i - 2}.Person Plural"
      else pers_numerus = "Infinitiv"
    end
  end
  pers_numerus = pers_numerus i
 
 
  def modus (pers_numerus, verb, forms, ending)
    if pers_numerus == "Infinitiv" 
      modus = ""
    # elsif verb =~ /#{forms[1]}a#{ending}/ #e-MischKonj.
      # modus = "Konjunktiv"
    else modus = "Indikativ" 
    end  
  end
  modus = modus pers_numerus, verb, forms, ending
  print "#{stem} \n"
  print ending
  #print "#{forms[1]}a#{ending}"

  
  def tempus (verb, ending, forms) #s, j, i)                 
    if verb.match(/ba#{ending}\b/)        #check tense (Imp)::: PRoblem: ba, momentan überall im Wort gesucht, mind 1 Buchstabe muss vor ihm sein, weiß nicht ob das alle Wörter abdeckt...
      tempus = "Imperfekt"
    elsif verb.match(/b[oiu]#{ending}/) 
      tempus = "Futur"
    elsif verb.match(/e#{ending}\b/) #kons., i-, misch. 2-6pers
      tempus = "Futur"
    elsif verb =~ /#{forms[1]}a[mr]/ 
      tempus = "Futur"   #i = 0: 1st-pers    
    else tempus = "Praesens"   #Annahme immer Präsens /nubit-Problem nicht gelöst
    end   
  end 
  tempus = tempus verb, ending, forms 

       
  def genus (j) 
    j < 2 ? genus = "Aktiv" : genus = "Passiv" #kürzer als früher
  end
  genus = genus j
  

  
  
  print "#{pers_numerus} #{modus} #{tempus} #{genus}, #{konjugation} \n" #output

end

if __FILE__ == $PROGRAM_NAME
#  verb = input 
#  print verb
  verb = "" 
  @looper = true
  while  
    verb = input
    if verb == "quit"
      break
    else
    define_verb(verb) 
    end

  end
end

