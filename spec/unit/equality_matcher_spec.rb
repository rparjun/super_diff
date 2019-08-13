require "spec_helper"

RSpec.describe SuperDiff::EqualityMatcher do
  describe "#call" do
    context "given the same integers" do
      it "returns an empty string" do
        output = described_class.call(expected: 1, actual: 1)

        expect(output).to eq("")
      end
    end

    context "given the same numbers (even if they're different types)" do
      it "returns an empty string" do
        output = described_class.call(expected: 1, actual: 1.0)

        expect(output).to eq("")
      end
    end

    context "given differing numbers" do
      it "returns a message along with a comparison" do
        actual_output = described_class.call(expected: 42, actual: 1)

        expected_output = <<~STR.strip
          Differing numbers.

          #{
            colored do
              red_line   %(Expected: 42)
              green_line %(  Actual: 1)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same symbol" do
      it "returns an empty string" do
        output = described_class.call(expected: :foo, actual: :foo)

        expect(output).to eq("")
      end
    end

    context "given differing symbols" do
      it "returns a message along with a comparison" do
        actual_output = described_class.call(expected: :foo, actual: :bar)

        expected_output = <<~STR.strip
          Differing symbols.

          #{
            colored do
              red_line   %(Expected: :foo)
              green_line %(  Actual: :bar)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same string" do
      it "returns an empty string" do
        output = described_class.call(expected: "", actual: "")

        expect(output).to eq("")
      end
    end

    context "given completely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "Marty",
          actual: "Jennifer",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              red_line   %(Expected: "Marty")
              green_line %(  Actual: "Jennifer")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "Marty",
          actual: "Marty McFly",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              red_line   %(Expected: "Marty")
              green_line %(  Actual: "Marty McFly")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's a line\nAnd there's a line too",
          actual: "This is a line\nSomething completely different\nAnd there's a line too",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              red_line   %(Expected: "This is a line⏎And that's a line⏎And there's a line too")
              green_line %(  Actual: "This is a line⏎Something completely different⏎And there's a line too")
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  This is a line⏎)
              red_line   %(- And that's a line⏎)
              green_line %(+ Something completely different⏎)
              plain_line %(  And there's a line too)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given completely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's a line\n",
          actual: "Something completely different\nAnd something else too\n",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              red_line   %(Expected: "This is a line⏎And that's a line⏎")
              green_line %(  Actual: "Something completely different⏎And something else too⏎")
            end
          }

          Diff:

          #{
            colored do
              red_line   %(- This is a line⏎)
              red_line   %(- And that's a line⏎)
              green_line %(+ Something completely different⏎)
              green_line %(+ And something else too⏎)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same array" do
      it "returns an empty string" do
        output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["sausage", "egg", "cheese"],
        )

        expect(output).to eq("")
      end
    end

    context "given two equal-length, one-dimensional arrays with differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, 3, 4],
          actual: [1, 2, 99, 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [1, 2, 3, 4])
              green_line %(  Actual: [1, 2, 99, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              red_line   %(-   3,)
              green_line %(+   99,)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing symbols" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [:one, :fish, :two, :fish],
          actual: [:one, :FISH, :two, :fish],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [:one, :fish, :two, :fish])
              green_line %(  Actual: [:one, :FISH, :two, :fish])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    :one,)
              red_line   %(-   :fish,)
              green_line %(+   :FISH,)
              plain_line %(    :two,)
              plain_line %(    :fish)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["bacon", "egg", "cheese"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: ["sausage", "egg", "cheese"])
              green_line %(  Actual: ["bacon", "egg", "cheese"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              red_line   %(-   "sausage",)
              green_line %(+   "bacon",)
              plain_line %(    "egg",)
              plain_line %(    "cheese")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            SuperDiff::Test::Person.new(name: "Marty", age: 18),
            SuperDiff::Test::Person.new(name: "Jennifer", age: 17),
          ],
          actual: [
            SuperDiff::Test::Person.new(name: "Marty", age: 18),
            SuperDiff::Test::Person.new(name: "Doc", age: 50),
          ],
          extra_operational_sequencer_classes: [
            SuperDiff::Test::PersonOperationalSequencer,
          ],
          extra_diff_formatter_classes: [
            SuperDiff::Test::PersonDiffFormatter,
          ],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Jennifer", age: 17>])
              green_line %(  Actual: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Doc", age: 50>])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    #<SuperDiff::Test::Person {)
              plain_line %(      name: "Marty",)
              plain_line %(      age: 18)
              plain_line %(    }>,)
              plain_line %(    #<SuperDiff::Test::Person {)
              red_line   %(-     name: "Jennifer",)
              green_line %(+     name: "Doc",)
              red_line   %(-     age: 17)
              green_line %(+     age: 50)
              plain_line %(    }>)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the end" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread"],
          actual: ["bread", "eggs", "milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: ["bread"])
              green_line %(  Actual: ["bread", "eggs", "milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "bread",)
              green_line %(+   "eggs",)
              green_line %(+   "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements missing from the end" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread", "eggs", "milk"],
          actual: ["bread"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: ["bread", "eggs", "milk"])
              green_line %(  Actual: ["bread"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "bread")
              red_line   %(-   "eggs",)
              red_line   %(-   "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the beginning" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["milk"],
          actual: ["bread", "eggs", "milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: ["milk"])
              green_line %(  Actual: ["bread", "eggs", "milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              green_line %(+   "bread",)
              green_line %(+   "eggs",)
              plain_line %(    "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements removed from the beginning" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread", "eggs", "milk"],
          actual: ["milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: ["bread", "eggs", "milk"])
              green_line %(  Actual: ["milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              red_line   %(-   "bread",)
              red_line   %(-   "eggs",)
              plain_line %(    "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, [:a, :b, :c], 4],
          actual: [1, 2, [:a, :x, :c], 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [1, 2, [:a, :b, :c], 4])
              green_line %(  Actual: [1, 2, [:a, :x, :c], 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    [)
              plain_line %(      :a,)
              red_line   %(-     :b,)
              green_line %(+     :x,)
              plain_line %(      :c)
              plain_line %(    ],)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, { foo: "bar", baz: "qux" }, 4],
          actual: [1, 2, { foo: "bar", baz: "qox" }, 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [1, 2, { foo: "bar", baz: "qux" }, 4])
              green_line %(  Actual: [1, 2, { foo: "bar", baz: "qox" }, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    {)
              plain_line %(      foo: "bar",)
              red_line   %(-     baz: "qux")
              green_line %(+     baz: "qox")
              plain_line %(    },)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, SuperDiff::Test::Person.new(name: "Marty", age: 18), 4],
          actual: [1, 2, SuperDiff::Test::Person.new(name: "Doc", age: 50), 4],
          extra_operational_sequencer_classes: [
            SuperDiff::Test::PersonOperationalSequencer,
          ],
          extra_diff_formatter_classes: [
            SuperDiff::Test::PersonDiffFormatter,
          ],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [1, 2, #<SuperDiff::Test::Person name: "Marty", age: 18>, 4])
              green_line %(  Actual: [1, 2, #<SuperDiff::Test::Person name: "Doc", age: 50>, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    #<SuperDiff::Test::Person {)
              red_line   %(-     name: "Marty",)
              green_line %(+     name: "Doc",)
              red_line   %(-     age: 18)
              green_line %(+     age: 50)
              plain_line %(    }>,)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            [
              :h1,
              [:span, [:text, "Hello world"]],
              {
                class: "header",
                data: { "sticky" => true },
              },
            ],
          ],
          actual: [
            [
              :h2,
              [:span, [:text, "Goodbye world"]],
              {
                id: "hero",
                class: "header",
                data: { "sticky" => false, role: "deprecated" },
              },
            ],
            :br,
          ],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              red_line   %(Expected: [[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true } }]])
              green_line %(  Actual: [[:h2, [:span, [:text, "Goodbye world"]], { id: "hero", class: "header", data: { "sticky" => false, :role => "deprecated" } }], :br])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    [)
              red_line   %(-     :h1,)
              green_line %(+     :h2,)
              plain_line %(      [)
              plain_line %(        :span,)
              plain_line %(        [)
              plain_line %(          :text,)
              red_line   %(-         "Hello world")
              green_line %(+         "Goodbye world")
              plain_line %(        ])
              plain_line %(      ],)
              plain_line %(      {)
              green_line %(+       id: "hero",)
              plain_line %(        class: "header",)
              plain_line %(        data: {)
              red_line   %(-         "sticky" => true)
              green_line %(+         "sticky" => false,)
              green_line %(+         role: "deprecated")
              plain_line %(        })
              plain_line %(      })
              plain_line %(    ],)
              green_line %(+   :br)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same hash" do
      it "returns an empty string" do
        output = described_class.call(
          expected: { name: "Marty" },
          actual: { name: "Marty" },
        )

        expect(output).to eq("")
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: 12, grande: 19, venti: 20 },
          actual: { tall: 12, grande: 16, venti: 20 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { tall: 12, grande: 19, venti: 20 })
              green_line %(  Actual: { tall: 12, grande: 16, venti: 20 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: 12,)
              red_line   %(-   grande: 19,)
              green_line %(+   grande: 16,)
              plain_line %(    venti: 20)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where keys are strings and the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { "tall" => 12, "grande" => 19, "venti" => 20 },
          actual: { "tall" => 12, "grande" => 16, "venti" => 20 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { "tall" => 12, "grande" => 19, "venti" => 20 })
              green_line %(  Actual: { "tall" => 12, "grande" => 16, "venti" => 20 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    "tall" => 12,)
              red_line   %(-   "grande" => 19,)
              green_line %(+   "grande" => 16,)
              plain_line %(    "venti" => 20)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing symbols" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: :small, grande: :grand, venti: :large },
          actual: { tall: :small, grande: :medium, venti: :large },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { tall: :small, grande: :grand, venti: :large })
              green_line %(  Actual: { tall: :small, grande: :medium, venti: :large })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: :small,)
              red_line   %(-   grande: :grand,)
              green_line %(+   grande: :medium,)
              plain_line %(    venti: :large)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: "small", grande: "grand", venti: "large" },
          actual: { tall: "small", grande: "medium", venti: "large" },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { tall: "small", grande: "grand", venti: "large" })
              green_line %(  Actual: { tall: "small", grande: "medium", venti: "large" })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: "small",)
              red_line   %(-   grande: "grand",)
              green_line %(+   grande: "medium",)
              plain_line %(    venti: "large")
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            steve: SuperDiff::Test::Person.new(name: "Jobs", age: 30),
            susan: SuperDiff::Test::Person.new(name: "Kare", age: 27),
          },
          actual: {
            steve: SuperDiff::Test::Person.new(name: "Wozniak", age: 33),
            susan: SuperDiff::Test::Person.new(name: "Kare", age: 27),
          },
          extra_operational_sequencer_classes: [
            SuperDiff::Test::PersonOperationalSequencer,
          ],
          extra_diff_formatter_classes: [
            SuperDiff::Test::PersonDiffFormatter,
          ],
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { steve: #<SuperDiff::Test::Person name: "Jobs", age: 30>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
              green_line %(  Actual: { steve: #<SuperDiff::Test::Person name: "Wozniak", age: 33>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    steve: #<SuperDiff::Test::Person {)
              red_line   %(-     name: "Jobs",)
              green_line %(+     name: "Wozniak",)
              red_line   %(-     age: 30)
              green_line %(+     age: 33)
              plain_line %(    }>,)
              plain_line %(    susan: #<SuperDiff::Test::Person {)
              plain_line %(      name: "Kare",)
              plain_line %(      age: 27)
              plain_line %(    }>)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has extra keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5 },
          actual: { latte: 4.5, mocha: 3.5, cortado: 3 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { latte: 4.5 })
              green_line %(  Actual: { latte: 4.5, mocha: 3.5, cortado: 3 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    latte: 4.5,)
              green_line %(+   mocha: 3.5,)
              green_line %(+   cortado: 3)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has missing keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5, mocha: 3.5, cortado: 3 },
          actual: { latte: 4.5 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { latte: 4.5, mocha: 3.5, cortado: 3 })
              green_line %(  Actual: { latte: 4.5 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    latte: 4.5)
              red_line   %(-   mocha: 3.5,)
              red_line   %(-   cortado: 3)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            name: "Elliot",
            interests: ["music", "football", "programming"],
            age: 30,
          },
          actual: {
            name: "Elliot",
            interests: ["music", "travel", "programming"],
            age: 30,
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { name: "Elliot", interests: ["music", "football", "programming"], age: 30 })
              green_line %(  Actual: { name: "Elliot", interests: ["music", "travel", "programming"], age: 30 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    name: "Elliot",)
              plain_line %(    interests: [)
              plain_line %(      "music",)
              red_line   %(-     "football",)
              green_line %(+     "travel",)
              plain_line %(      "programming")
              plain_line %(    ],)
              plain_line %(    age: 30)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            check_spelling: true,
            substitutions: {
              "YOLO" => "You only live once",
              "BRB" => "Buns, ribs, and bacon",
              "YMMV" => "Your mileage may vary",
            },
            check_grammar: false,
          },
          actual: {
            check_spelling: true,
            substitutions: {
              "YOLO" => "You only live once",
              "BRB" => "Be right back",
              "YMMV" => "Your mileage may vary",
            },
            check_grammar: false,
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Buns, ribs, and bacon", "YMMV" => "Your mileage may vary" }, check_grammar: false })
              green_line %(  Actual: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Be right back", "YMMV" => "Your mileage may vary" }, check_grammar: false })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    check_spelling: true,)
              plain_line %(    substitutions: {)
              plain_line %(      "YOLO" => "You only live once",)
              red_line   %(-     "BRB" => "Buns, ribs, and bacon",)
              green_line %(+     "BRB" => "Be right back",)
              plain_line %(      "YMMV" => "Your mileage may vary")
              plain_line %(    },)
              plain_line %(    check_grammar: false)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            order_id: 1234,
            person: SuperDiff::Test::Person.new(name: "Marty", age: 18),
            amount: 350_00,
          },
          actual: {
            order_id: 1234,
            person: SuperDiff::Test::Person.new(name: "Doc", age: 50),
            amount: 350_00,
          },
          extra_operational_sequencer_classes: [
            SuperDiff::Test::PersonOperationalSequencer,
          ],
          extra_diff_formatter_classes: [
            SuperDiff::Test::PersonDiffFormatter,
          ],
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Marty", age: 18>, amount: 35000 })
              green_line %(  Actual: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Doc", age: 50>, amount: 35000 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    order_id: 1234,)
              plain_line %(    person: #<SuperDiff::Test::Person {)
              red_line   %(-     name: "Marty",)
              green_line %(+     name: "Doc",)
              red_line   %(-     age: 18)
              green_line %(+     age: 50)
              plain_line %(    }>,)
              plain_line %(    amount: 35000)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            customer: {
              name: "Marty McFly",
              shipping_address: {
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              },
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"],
              },
              { name: "Chevy 4x4" },
            ],
          },
          actual: {
            customer: {
              name: "Marty McFly, Jr.",
              shipping_address: {
                line_1: "456 Ponderosa Ct.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              },
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"],
              },
              { name: "Mattel Hoverboard" },
            ],
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              red_line   %(Expected: { customer: { name: "Marty McFly", shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] })
              green_line %(  Actual: { customer: { name: "Marty McFly, Jr.", shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    customer: {)
              red_line   %(-     name: "Marty McFly",)
              green_line %(+     name: "Marty McFly, Jr.",)
              plain_line %(      shipping_address: {)
              red_line   %(-       line_1: "123 Main St.",)
              green_line %(+       line_1: "456 Ponderosa Ct.",)
              plain_line %(        city: "Hill Valley",)
              plain_line %(        state: "CA",)
              plain_line %(        zip: "90382")
              plain_line %(      })
              plain_line %(    },)
              plain_line %(    items: [)
              plain_line %(      {)
              plain_line %(        name: "Fender Stratocaster",)
              plain_line %(        cost: 100000,)
              plain_line %(        options: [)
              plain_line %(          "red",)
              plain_line %(          "blue",)
              plain_line %(          "green")
              plain_line %(        ])
              plain_line %(      },)
              plain_line %(      {)
              red_line   %(-       name: "Chevy 4x4")
              green_line %(+       name: "Mattel Hoverboard")
              plain_line %(      })
              plain_line %(    ])
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two objects which == each other" do
      it "returns an empty string" do
        expected = SuperDiff::Test::Person.new(name: "Marty", age: 18)
        actual = SuperDiff::Test::Person.new(name: "Marty", age: 18)

        output = described_class.call(expected: expected, actual: actual)

        expect(output).to eq("")
      end
    end

    context "given two objects which do not == each other" do
      it "returns a message along with a comparison" do
        expected = SuperDiff::Test::Person.new(name: "Marty", age: 18)
        actual = SuperDiff::Test::Person.new(name: "Doc", age: 50)

        actual_output = described_class.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: [
            SuperDiff::Test::PersonOperationalSequencer,
          ],
          extra_diff_formatter_classes: [
            SuperDiff::Test::PersonDiffFormatter,
          ],
        )

        expected_output = <<~STR.strip
          Differing objects.

          #{
            colored do
              red_line   %(Expected: #<SuperDiff::Test::Person name: "Marty", age: 18>)
              green_line %(  Actual: #<SuperDiff::Test::Person name: "Doc", age: 50>)
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  #<SuperDiff::Test::Person {)
              red_line   %(-   name: "Marty",)
              green_line %(+   name: "Doc",)
              red_line   %(-   age: 18)
              green_line %(+   age: 50)
              plain_line %(  }>)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end
  end

  def colored(&block)
    SuperDiff::Tests::Colorizer.call(&block).chomp
  end
end
