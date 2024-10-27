import os
import shutil
import subprocess
import sys
import filecmp

# Config paths
blog_target = r'D:\workplace\Blog\source'
source = r'D:\workplace\Self-study-notes'

def move_files():
    print("-----move files-----")
    # Move files logic
    renew_files()
    print("-----move files finished-----")
    clean_and_generate()

def renew_files():
    print("-----renew files-----")
    # Traverse all .md files in source directory and update them
    for root, _, files in os.walk(source):
        for file in files:
            if file.endswith('.md') and file != "README.md":
                src_path = os.path.join(root, file)
                dest_path = os.path.join(blog_target, '_posts', file)
                if os.path.exists(dest_path):
                    # Compare files, if different, copy
                    if not filecmp.cmp(src_path, dest_path, shallow=False):
                        shutil.copy2(src_path, dest_path)
                        print(f"{src_path} copied to {dest_path}")
                else:
                    shutil.copy2(src_path, dest_path)
                    print(f"{src_path} copied to {dest_path}")
    print("-----renew files finished-----")

def clean_and_generate():
    print("-----clean and generate-----")
    os.chdir(os.path.join(blog_target, '..'))
    subprocess.run(['npx', 'hexo', 'clean'])
    subprocess.run(['npx', 'hexo', 'generate'])
    print("-----clean and generate finished-----")

def start_server():
    print("-----hexo server-----")
    os.chdir(os.path.join(blog_target, '..'))
    subprocess.run(['npx', 'hexo', 'server'])

def deploy():
    print("-----hexo deploy-----")
    os.chdir(os.path.join(blog_target, '..'))
    subprocess.run(['npx', 'hexo', 'deploy'])

def git_commit():
    print("-----git commit-----")
    subprocess.run(['git', 'add', '.'])
    subprocess.run(['git', 'commit', '-m', "Daily reading experience"])
    print("-----git commit completed-----")

def git_push():
    print("-----git push-----")
    subprocess.run(['git', 'push'])
    print("-----git push completed-----")

# Get command-line argument
command = sys.argv[1] if len(sys.argv) > 1 else None

# Command control flow
if command == "-m":
    move_files()
elif command == "-r":
    renew_files()
elif command == "-s":
    move_files()
    start_server()
elif command == "-d":
    move_files()
    deploy()
elif command == "-ss":
    start_server()
elif command == "-sd":
    deploy()
elif command == "-c":
    git_commit()
elif command == "-p":
    git_push()
else:
    print("ERROR: Incorrect parameter list.")
