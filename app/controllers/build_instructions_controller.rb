class BuildInstructionsController < ApplicationController
  before_filter {
    @project = sandbox.project.find(params[:project_id])
    @repository = @project.repositories.find(params[:repository_id])
  }

  def destroy
    @build_instruction = @repository.build_instructions.find(params[:id])
    @build_instruction.destroy
  end

  def new
    @build_instruction = @repository.build_instructions.create(script: "replace me with a very small shell-script")
    render :update do |page|
      page.insert_html(
        :bottom, 'build-instructions',
        { partial: 'repositories/build_instruction',
          object: @build_instruction,
          layout: 'layouts/script'
        }
      )
    end
  end

  def update
    @build_instruction = @repository.build_instructions.find(params[:id])

    script = sanitize params[:script]
    unless script.blank?
      @build_instruction.update_attributes(script: script)
    end

    render :update do |page|
      page.replace_html(
        "instruction-script-#{@build_instruction.id}",
        @build_instruction.script
      )
      page.visual_effect :pulsate, "instruction-script-#{@build_instruction.id}"
    end
  end

  def sanitize(script)
    script.gsub!(/[\r\n]/, '')
    script.gsub!(/\.\.\//, '')
    return script
  end
end

