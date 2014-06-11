from fabric.api import local, env, lcd
import os

env.venv_path = "%s/forms" % os.environ['WORKON_HOME']
env.project_path = os.path.dirname(env.real_fabfile)
env.mode = "dev"

def pm(cmd="help", args="", mode="dev"):
    with lcd(env.project_path):
        local("%s/bin/python manage.py %s --settings=django_site.settings.%s %s" % (
            env.venv_path, cmd, mode, args
        ))

def server(mode="dev"):
    pm("runserver", "", mode)

def test(labels=""):
    pm("test", labels)
