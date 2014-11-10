# encoding: utf-8

center <<-EOS
	center
	some text
EOS

tableofcontents
tableofcontents "Custom Headline"

block <<-EOS
	block
	some text
EOS

section "my first section" do
	center "first slide"
	block "second slide"
end

section "my second slide" do
	center "slide a"
	center "slide b"
end


