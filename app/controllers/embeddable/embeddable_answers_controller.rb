class Embeddable::EmbeddableAnswersController < ApplicationController
  class << self; attr_accessor :embeddable_type end

  before_filter :set_answer
  before_filter :authorize_run_access

  private

  def set_answer
    @answer = self.class.embeddable_type.find(params[:id])
  end

  def authorize_run_access
    raise_error_if_not_authorized_run(@answer.run)
  end
end
