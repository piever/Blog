using GitHub, Downloads

function get_tag_info(tag::GitHub.Tag)
    str = sprint() do io
        Downloads.download(tag.object["url"], io)
    end
    dict = JSON.parse(str)
    parts = splitpath(tag.url.path) # why is this not straight-forward?
    repo = GitHub.Repo(parts[3] * "/" * parts[4])
    return (
        commit = dict["object"]["sha"],
        name = dict["tag"],
        repo = repo,
        message = dict["message"],
    )
end

function commits_between(tag1, tag2, auth; repo="JuliaPlots/Makie.jl")
    t1 = GitHub.tag(repo, "v0.16.5")
    t2 = GitHub.tag(repo, "v0.15.3")
    t1info = get_tag_info(t1)
    t2info = get_tag_info(t2)
    params = Dict("per_page" => 100)
    commits, _ = GitHub.commits(repo; auth=auth, params)

    idx1 = findfirst(x-> x.sha == t1info.commit, commits)
    idx2 = findfirst(x-> x.sha == t2info.commit, commits)

    return commits[min(idx1, idx2):max(idx1, idx2)]
end
