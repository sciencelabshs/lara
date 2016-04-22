class QuestionTracker < ActiveRecord::Base
  attr_accessible :master_question, :questions, :name, :description, :owner

  belongs_to :master_question, polymorphic: true
  has_many :tracked_questions

  def correct_type(question)
    question.is_a? self.master_question.class
  end

  def questions
    [master_question] + tracked_questions.map { |tq| tq.question }
  end

  def add_question(question)
    if (correct_type(question))
      unless questions.include? question
        self.tracked_questions.create(question: question, question_tracker: self)
        return true
      end
    end
    return false
  end

  def new_question()
    new_q = master_question.duplicate
    new_q.save
    add_question(new_q)
  end

  def remove_question(question)
    tracked_questions.where(question_id: question, question_type: question.class.name).each { |q| q.delete }
    tracked_questions.reload
    question.reload
  end

end