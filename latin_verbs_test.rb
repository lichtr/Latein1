require './latin_verbs.rb'
require 'minitest/autorun'

describe "Stems search" do
it "stem = am for amas" do
@input = "amas"
@stem must equal ("ama")
end
end
