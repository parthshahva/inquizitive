class UseOnline < UseCase
  def run(inputs)
    user = User.first(:phone_number => inputs[:phone_number])
    question_set = Questionset.first(:id => inputs[:questionset_id])
    question = Question.first(:id => inputs[:question_id])
    question_set_id = question.questionset_id


    answer_checker = false
    answer_checker = true if question.answer.downcase == inputs[:answer].downcase
    response = "Incorrect"
    response = "correct" if answer_checker == true

    questions = Question.all(:questionset_id => question_set.id)
    return failure(:no_questions_in_set) if questions == []
    Response.create(:correct => answer_checker, :question_id => question.id, :user_id => user.id, :questionset_id => question.questionset_id, :time => Time.now)

    current_question = Question.first(:questionset_id => question_set_id)
    percentages = []
    if rand(0..2) != 0
      number = questions.count - 1
      current_question_id = rand(0..number)
      current_question = questions[current_question_id]


    else
      question_hash = {}

      questions.each do |question|
        question_responses = Response.all(:question => question.id, :user => user.id)
        question_hash[question.id] = {:correct => 0, :incorrect => 0}
        question_responses.each do |response|
          if response.correct
            question_hash[question.id][:correct] += 1
          else
            question_hash[question.id][:incorrect] += 1
          end
        end
      end

      question_hash.each do |qid, tally|
        if tally[:correct] + tally[:incorrect] != 0
        percentages.push({:question_id => qid, :percent_correct => tally[:correct]/(tally[:correct] + tally[:incorrect])})
        else
          percentages.push({:question_id => qid, :percent_correct => 0})
        end
      end
  percentages.sort_by! { |hash| hash[:percent_correct]}
  index = (rand(questions.count)/2)
  current_question = Question.first(:id => percentages[index][:question_id])
  end

  if questions.count > 1
    while question.id == current_question.id
      number = questions.count - 1
      current_question_id = rand(0..number)
      current_question = questions[current_question_id]
    end
  end

    message = current_question.text

    if response == "correct"
      user.correct_counter += 1
      if user.correct_counter > user.longest_correct_streak
        user.longest_correct_streak = user.correct_counter
      end
      user.save
      success :correct => "Correct", :current_question => current_question
    else
      user.correct_counter = 0
      user.save
      success :correct => "Incorrect", :current_question => current_question
    end
  end
end

