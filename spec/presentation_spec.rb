require './spec_helper.rb'
require 'presentation'
require 'slide'
require 'slide_part'
require 'markdown_slide_part'
require 'image_slide_part'

describe Presentation do
	before(:each) do
		@presentation = Presentation.new
	end

	after(:each) do
		Presentation.destroy_all
	end

	it "should have a name" do
		@presentation.should respond_to(:name=)
		@presentation.should respond_to(:name)
		@presentation.name = 'Test'
		@presentation.name.should eq('Test')
	end

	it "should have an author" do
		@presentation.should respond_to(:author=)
		@presentation.should respond_to(:author)
		@presentation.author = 'Test'
		@presentation.author.should eq('Test')
	end

	describe Slide do
		before(:each) do
			@slide = @presentation.slides.build()
		end

		it "should have a title" do
			@slide.should respond_to(:title=)
			@slide.should respond_to(:title)
			@slide.title = 'Test'
			@slide.title.should eq('Test')
		end

		it "should have a subtitle" do
			@slide.should respond_to(:subtitle=)
			@slide.should respond_to(:subtitle)
			@slide.subtitle = 'Test'
			@slide.subtitle.should eq('Test')
		end

		describe SlidePart do
			before(:each) do
				@slide_part = @slide.slide_parts.create(:type => :image, :path => "")
			end
 
			it "should have a type" do
				@slide_part.type.should eq(:image)
			end

			context "Markdown-based Slide Part" do
				before(:each) do
					@markdown_slide_part = @slide.slide_parts.create(:type => :markdown)
				end

				it "should have a type of markdown" do
					@markdown_slide_part.type.should eq(:markdown)
				end

				it "should have content" do
					@markdown_slide_part.should respond_to(:content=)
					@markdown_slide_part.should respond_to(:content)
					@markdown_slide_part.content = '# Header 1'
					@markdown_slide_part.content.should eq('# Header 1')
				end
			end
			context "Image-based Slide Part" do
				before(:each) do
					@image_slide_part = @slide.slide_parts.create(:type => :image)
				end

				it "should have a type of image" do
					@image_slide_part.type.should eq(:image)
				end

				it "should have a path" do
					@image_slide_part.should respond_to(:path=)
					@image_slide_part.should respond_to(:path)
					@image_slide_part.path = 'image.png'
					@image_slide_part.path.should eq('image.png')
				end
			end
		end
	end

	it "has slides" do
		@presentation.should respond_to(:slides)
		@presentation.slides.should respond_to(:length)
	end

	context "Adding a Slide" do
		before(:each) do
			@presentation = Presentation.create!(:name => "Test Preso", :author => "Me")
		end

		it "should add a new title and subtitle" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			slide.persisted?.should be_true
			@presentation.slides.length.should eq(1)
			@presentation.slides.first.title.should eq("Test Title")
			@presentation.slides.first.subtitle.should eq("Test Subtitle")
		end

		it "should keep the slides in the correct order" do
			@presentation.slides.create(:title => "Slide 1", :subtitle => "Test Subtitle")
			@presentation.slides.create(:title => "Slide 2", :subtitle => "Test Subtitle")
			@presentation = Presentation.find(@presentation.id)
			@presentation.name.should_not be_nil
			@presentation.author.should_not be_nil
			@presentation.slides.length.should eq(2)
			@presentation.slides.first.title.should eq("Slide 1")
			@presentation.slides.second.title.should eq("Slide 2")
		end
	end

	context "Editing a Slide" do
		before(:each) do
			@presentation = Presentation.create!(:name => "Test Preso", :author => "Me")
		end

		it "should allow adding a markdown slide part" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			@part = slide.slide_parts.create(:slide_type => :markdown, :content => "# Header 1")
			@part.position.should eq(0)
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.first.content.should eq("# Header 1")
		end

		it "should allow adding an image slide part" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			@part = slide.slide_parts.create(:slide_type => :image, :path => "test.png" )
			@part.position.should eq(0)
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.first.path.should eq("test.png")
		end

		it "should add many slide parts correctly" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			part1 = slide.slide_parts.create(:slide_type => :image, :path => "test1.png" )
			part1.position.should eq(0)
			part2 = slide.slide_parts.create(:slide_type => :image, :path => "test2.png")
			part2.position.should eq(1)
		end
	end

	context "Removing a Slide" do
		before(:each) do
			@presentation = Presentation.create!(:name => "Test Preso", :author => "Me")
		end

		it "should allow removing a markdown slide part" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			slide.slide_parts.create(:slide_type => :markdown, :content => "# Header 1")
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.first.destroy
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.length.should eq(0)
		end

		it "should allow removing an image slide part" do
			slide = @presentation.slides.create(:title => "Test Title", :subtitle => "Test Subtitle")
			slide.slide_parts.create(:slide_type => :image, :path => "test.png")
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.first.destroy
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.first.slide_parts.length.should eq(0)
		end
	end

	context "Slide Ordering" do
		before(:each) do
			@presentation = Presentation.create!(:name => "Test Preso", :author => "Me")
			@presentation.slides.create(:title => "Slide 1", :subtitle => "Test Subtitle")
			@presentation.slides.create(:title => "Slide 2", :subtitle => "Test Subtitle")
			@presentation.slides.create(:title => "Slide 3", :subtitle => "Test Subtitle")
			@presentation = Presentation.find(@presentation.id)
		end

		it "should preserve order" do
			@presentation.slides.first.position.should eq(0)
			@presentation.slides.second.position.should eq(1)
			@presentation.slides.third.position.should eq(2)
		end

		it "should allow moving up a slide" do
			@presentation.slides.second.move(0)
			@presentation.slides.second.save
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.scoped.first.title.should eq("Slide 2")
			@presentation.slides.scoped.second.title.should eq("Slide 1")
			@presentation.slides.scoped.third.title.should eq("Slide 3")
			@presentation.slides.scoped.first.position.should eq(0)
			@presentation.slides.scoped.second.position.should eq(1)
			@presentation.slides.scoped.third.position.should eq(2)
		end
			
		it "should allow moving down a slide" do
			@presentation.slides.second.move(2)
			@presentation.slides.second.save
			@presentation = Presentation.find(@presentation.id)
			@presentation.slides.scoped.first.title.should eq("Slide 1")
			@presentation.slides.scoped.second.title.should eq("Slide 3")
			@presentation.slides.scoped.third.title.should eq("Slide 2")
			@presentation.slides.scoped.first.position.should eq(0)
			@presentation.slides.scoped.second.position.should eq(1)
			@presentation.slides.scoped.third.position.should eq(2)	
		end
	end
end