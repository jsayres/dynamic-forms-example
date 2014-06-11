import os
from optparse import make_option
import subprocess

from django.conf import settings
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = 'Import dist files from frontend'
    option_list = BaseCommand.option_list + (
        make_option(
            '--skip-build',
            action='store_true',
            dest='skip-build',
            default=False,
            help='Skip lineman build of assets'
        ),
    )

    def handle(self, *args, **options):
        base_dir = settings.BASE_DIR
        project_dir = os.path.join(base_dir, 'django_site')
        static_dir = os.path.join(project_dir, 'static')
        frontend_dir = settings.FRONTEND_DIR

        if not options['skip-build']:
            current_dir = os.getcwd()
            os.chdir(frontend_dir)
            cmd = ['lineman', 'build']
            kwargs = {'stdout': self.stdout, 'stderr': self.stderr}
            exit_status = subprocess.call(cmd, **kwargs)
            os.chdir(current_dir)
            if exit_status != 0:
                return

        _from = os.path.join(frontend_dir, 'dist', 'assets', '.')
        options = {'stdout': self.stdout, 'stderr': self.stderr}
        subprocess.call(['cp', '-R', _from, static_dir], **options)

        _from = os.path.join(frontend_dir, 'dist', 'index.html')
        _to = os.path.join(project_dir, 'templates', 'admin', 'admin.html')
        subprocess.call(['cp', _from, _to], **options)
