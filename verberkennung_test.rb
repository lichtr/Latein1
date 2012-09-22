require './Verberkennung15.rb'
require 'minitest/autorun'
require 'stringio'

describe "disable string output" do
  before do
    @stringio = StringIO.new
    @stdout_old = $stdout
    $stdout = @stringio
  end


  describe "define_verb tests" do

    it "should return Praesens" do
      define_verb("moneo")
      @stringio.string.must_equal("1.Person Singular Indikativ Praesens Aktiv, E-Konjugation \n")
    end

    it "should return Imperfekt" do
      define_verb("amabas")
      @stringio.string.must_equal("2.Person Singular Indikativ Imperfekt Aktiv, A-Konjugation \n")
    end

    it "should return something" do
      define_verb("laudo")
      @stringio.string.must_equal("1.Person Singular Indikativ Praesens Aktiv, A-Konjugation \n")
    end
# da kannst jetzt so viele it ... machen wie du willst. ist jetzt wirklich nur
    # sehr banal, weil immer nach der gesamten string ausgabe gefragt wird - man
    # könnte natürlich auch konkreter nach einzelnen aspekten fragen (in der
    # must_equal zeile), aber nachdem ich dein programm nicht so gut kenne, hab
    # ich das jetzt absichtlich nicht gemacht.







  end




  after do
    $stdout = @stdout_old
  end 

end
