class RunSMS < UseCase
  def run(inputs)
    user = User.first(:phone_number => inputs[:phone_number][2..-1])
    return failure(:user_does_not_exist) if user.nil?
    return failure(:session_not_active) if user.last_question_id.nil?

    question = Question.first(:id => user.last_question_id)
    question_set_id = question.questionset_id
    question_set = Questionset.first(:id => question_set_id)


    answer_checker = false
    answer_checker = true if question.answer.downcase == inputs[:answer].downcase
    response = "Incorrect"
    response = "correct" if answer_checker == true

    questions = Question.all(:questionset_id => question_set.id)
    return failure(:no_questions_in_set) if questions == []
    # Response.create(:correct => answer_checker, :question_id => question.id, :user_id => user.id)

    current_question = Question.first(:questionset_id => question_set_id)
    percentages = []
    if rand(0..1) == 1
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

    user.last_question_id = current_question.id
    user.save
    message = current_question.text

    if response == "correct"
      success :message => "Correct. #{message}"
    else
      success :message => "#{response}. The answer is #{question.answer}. #{message}"
    end
  end
end

