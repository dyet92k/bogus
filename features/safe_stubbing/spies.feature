Feature: Spies

  Object Oriented Programming is all about messages sent between the objects.  If you follow principles like "Tell, Don't Ask", you will enable yourself to combine Bogus's powerful feature of faking objects with it's ability to verify object interactions.

  Typically, stubbing libraries force you to first stub a method, so that you can later make sure it was called. However, if you use fakes, Bogus lets you verify that a method was called (or not) without stubbing it first.

  Background:
    Given a file named "library.rb" with:
    """ruby
    class Library
      def checkout(book)
        # marks book as checked out
      end
    end
    """

    Given a file named "student.rb" with:
    """ruby
    class Student
      def initialize(library)
        @library = library
      end

      def study(*book_titles)
        book_titles.each do |book_title|
          @library.checkout(book_title)
        end
      end
    end
    """

  Scenario: Ensuring methods were called
    Then spec file with following content should pass:
    """ruby
    require_relative 'student'
    require_relative 'library'

    describe Student do
      fake(:library)

      it "studies using books from library" do
        student = Student.new(library)

        student.study("Moby Dick", "Sherlock Holmes")

        expect(library).to have_received.checkout("Moby Dick")
        expect(library).to have_received.checkout("Sherlock Holmes")
      end
    end
    """

  Scenario: Spying on methods that do not exist
    Then spec file with following content should fail:
    """ruby
    require_relative 'student'
    require_relative 'library'

    describe Student do
      fake(:library)

      it "studies using books from library" do
        student = Student.new(library)

        student.study("Moby Dick")

        expect(library).not_to have_received.return_book("Moby Dick")
      end
    end
    """

  Scenario: Spying on methods with wrong number of arguments
    Then spec file with following content should fail:
    """ruby
    require_relative 'student'
    require_relative 'library'

    describe Student do
      fake(:library)

      it "studies using books from library" do
        student = Student.new(library)

        student.study("Moby Dick", "Sherlock Holmes")

        expect(library).not_to have_received.checkout("Moby Dick", 
          "Sherlock Holmes")
      end
    end
    """

  Scenario: Spying on previously stubbed methods
    Then spec file with following content should pass:
    """ruby
    require_relative 'student'
    require_relative 'library'

    describe Student do
      fake(:library)

      it "studies using books from library" do
        stub(library).checkout("Moby Dick") { "checked out" }

        expect(library.checkout("Moby Dick")).to eq("checked out")

        expect(library).to have_received.checkout("Moby Dick")
      end
    end
    """

  Scenario: Spying on attribute writers
    Given a file named "canvas.rb" with:
    """ruby
    class Canvas
      def background_color=(color)
        # do something complicated
      end
    end
    """

    Given a file named "popup.rb" with:
    """ruby
    class Popup
      def self.alert(message, canvas)
        canvas.background_color = "red"
        # display message
      end
    end
    """
   
    Then spec file with following content should pass:
    """ruby
    require_relative 'canvas'
    require_relative 'popup'

    describe Popup do
      fake(:canvas)

      it "sets the background to red" do
        Popup.alert("No such file!", canvas)

        expect(canvas).to have_received(:background_color=, "red")
      end
    end
    """
