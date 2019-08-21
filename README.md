# sandbox

## concourse-ci

I assume you have deployed concourse and you are logged in with fly:

```bash
fly login -t local --concourse-url <YOUR CONCOURSE URL> -u <CONCOURSE USERNAME> -p <CONCOURSE PASSWORD>
```

### RE-FLY A PIPELINE

#### Set a new pipeline

First set a new pipeline to display a semver version defined in a var passed through the command line.

The first pipeline is [version-pipeline.yml](https://github.com/bzhtux/sandbox/blob/master/pipelines/version-pipeline.yml)

Run this command to deploy this new pipeline:

```bash
$ fly -t local sp -p display-version -c pipelines/version-pipeline.yml --var version='0.0.1' -n
```

Unpause this fresh pipeline:

```bash
$ fly -t local up -p display-version
```

Trigger this pipeline and look what is happening:

```bash
$ fly -t local trigger-job -j display-version/display-version
```

Now you have a new pipeline that display '0.0.1' 🙂

#### Change version and re-fly pipeline

The new version is now stored in a file `concourse_repipe_version` :

```bash
$ cat concourse_repipe_version
0.0.2
```

Commit and push this file to a git repository.

To get the new version from this file, create a new pipeline file [update-version.yml](https://github.com/bzhtux/sandbox/blob/master/pipelines/update-version.yml) and add a semver resource:

```yaml
---
resources:
- name: version
  type: semver
  source:
    driver: git
    uri: https://github.com/bzhtux/sandbox.git
    branch: master
    initial_version: '0.0.1'
    file: concourse_repipe_version
```

This pipeline define a job to grab the new version from the file above and re-fly the pipeline `display-version` with the new version. All the magic stands in a [task](https://github.com/bzhtux/sandbox/blob/master/tasks/fly/fly.sh) file.

Run this command to deploy this new pipeline:

```bash
$ fly -t local sp -p update-version -c pipelines/update-version.yml --var username="<CONCOURSE USERNAME>" --var password="<CONCOURSE PASSWORD>" -n
```

Unpause this fresh pipeline:

```bash
$ fly -t local up -p update-version
```

Trigger this pipeline and look what is happening:

```bash
$ fly -t local trigger-job -j update-version/update-version
```