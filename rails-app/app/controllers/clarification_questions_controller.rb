class ClarificationQuestionsController < ApplicationController
  def create
    requirement = Requirement.find(params[:requirement_id])
    authorize! :manage_requirements, requirement.project
    question = requirement.clarification_questions.new(question_params.merge(asked_by: current_user))
    if question.save
      redirect_to requirement, notice: "Question added."
    else
      redirect_to requirement, alert: question.errors.full_messages.to_sentence
    end
  end

  def update
    question = ClarificationQuestion.find(params[:id])
    authorize! :manage_requirements, question.requirement.project
    if question.update(question_params.merge(answered_by: current_user, status: "answered"))
      redirect_to question.requirement, notice: "Question answered."
    else
      redirect_to question.requirement, alert: question.errors.full_messages.to_sentence
    end
  end

  private

  def question_params
    params.require(:clarification_question).permit(:question, :answer, :status)
  end
end
