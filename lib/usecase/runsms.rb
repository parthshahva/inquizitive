class RunSMS < UseCase
  def run(inputs)
    user = User.first(:phone_number => inputs[:phone_number][2..-1])
    return failure(:user_does_not_exist) if user.nil?
    return failure(:session_not_active) if user.last_question_id.nil?

    question = Question.first(:id => user.last_question_id)
    question_set = Questionset.first(:id => question.questionset_id)
    # return failure(:question_set_not_found) if question_set.nil?

    answer_checker = false
    answer_checker = true if question.answer.downcase == inputs[:answer].downcase
    response = "incorrect"
    response = "correct" if answer_checker == true

    questions = Question.all(:questionset_id => question_set.id)
    return failure(:no_questions_in_set) if questions == []
    Response.create(correct: answer_checker, question_id: question.id, user_id: user.id)

    if rand(0..1)
      number = questions.count
      current_question_id = rand(1..number)
      current_question = Question.get(current_question_id)
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

      percentages = []

      question_hash.each do |qid, tally|
        percentages.push({:question_id => qid, :percent_correct => tally[:correct]/(tally[:correct] + tally[:incorrect])})
      end

      percentages.sort_by! { |hash| hash[:percent_correct]}

      index = (rand(questions.count)/2)

      current_question = Question.get(percentages[index].key)
    end
    user.last_question_id = current_question_id
    user.save
    message = current_question.text
    if response == "correct"
      success :message => "Correct. #{message}"
    else
      success :message => "Incorrect. The answer was #{question.answer} #{message}"
    end
  end
end

