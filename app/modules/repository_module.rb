class RepositoryModule < Kindergarten::Perimeter
  purpose :repository

  expose :update
  def update(repo, args)
    args['build_environment'] = parse_env(args.delete('build_environment'))
    repo.update_attributes(scrub(args, :default_branch, :build_environment))
  end

  def parse_env(text)
    hash = {}
    text ||= ""
    text.split("\n").each do |pair|
      (key, value) = pair.split('=', 2)
      hash[key] = value.gsub(/(\A['"]|['"]\z)/, '')
    end

    return hash
  end
end
