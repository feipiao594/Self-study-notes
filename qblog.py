import os
import shutil
import subprocess
import sys
import filecmp
import time
import re

from colorama import Fore, Style

# Config paths
blog_target = r'/home/feipiao/Workplace/Blog/BlogSrc'
source = r'/home/feipiao/Workplace/Blog/Self-study-notes'
log_state = 1

def error(str):
    print(Fore.RED + get_time() + "[Error]" + Style.RESET_ALL + f" qblog: {str}")

def success(str):
    print(Fore.GREEN + get_time() + "[Success]" + Style.RESET_ALL + f" qblog: {str}")

def change(str):
    print(Fore.CYAN + get_time() + "[Change]" + Style.RESET_ALL + f" qblog: {str}")

def warning(str):
    if log_state <= 2:
        print(Fore.YELLOW + get_time() + "[Warning]" + Style.RESET_ALL + f" qblog: {str}")

def info(str):
    if log_state <= 1:
        print(Fore.BLUE + get_time() + "[Info]" + Style.RESET_ALL + f" qblog: {str}")

def debug(str):
    if log_state <= 0:
        print(Fore.MAGENTA + get_time() + "[Debug]" + Style.RESET_ALL + f" qblog: {str}")

def get_time():
    return time.strftime("[%H:%M]", time.localtime())

def check_categorys():
    src_md_files = list_md_files(source)
    unmatch_files = []
    for file, root in src_md_files:
        relative_path = os.path.relpath(root, source)
        categories = relative_path.split(os.sep)
        with open(os.path.join(root, file), 'r') as f:
            lines = f.readlines()
        
        start_idx = None
        category_idx = None
        end_idx = None
        for i, line in enumerate(lines):
            if line.strip() == 'categories:':
                if start_idx is not None:
                        category_idx = i
            if line.strip() == '---':
                if start_idx is None:
                    start_idx = i
                else:
                    if category_idx is not None:
                        end_idx = i
                    break
        
        if end_idx is None:
            unmatch_files.append(os.path.relpath(os.path.join(root, file), source))
            break
        

        j = 0
        for i in range(category_idx+1, end_idx):
            j += 1
            str = lines[i].strip()
            if str.startswith('-'):
                if j > len(categories):
                    unmatch_files.append(os.path.relpath(os.path.join(root, file), source))
                    break
            else:
                if j <= len(categories):
                    unmatch_files.append(os.path.relpath(os.path.join(root, file), source))
                break
            if not re.match(rf'-\s*{re.escape(categories[j-1])}\s*$', lines[i].strip()):
                unmatch_files.append(os.path.relpath(os.path.join(root, file), source))
                break
        
        # Check if there are subdirectories in the current directory
        if any(os.path.isdir(os.path.join(root, d)) for d in os.listdir(root)):
            unmatch_files.append(os.path.relpath(os.path.join(root, file), source))
        
    if len(unmatch_files) == 0:
        success("All files are matched.")
        return True
    else:
        error("Unmatch files:")
        for file in unmatch_files:
            print(file)
        return False

def list_md_files(path):
    md_files = []
    for root, _, files in os.walk(path):
        for file in files:
            if file.endswith('.md') and file != "README.md":
                md_files.append((file, root))
    return md_files

def move_files():
    info("move files")
    # Move .md files
    md_files = list_md_files(source)
    dest_md_files = list_md_files(os.path.join(blog_target, 'source/_posts'))
    for file, root in md_files:
        src_path = os.path.relpath(os.path.join(root, file), source)
        dest_path = os.path.join(blog_target, 'source/_posts', file)
        
        if os.path.exists(dest_path):
            dest_md_files.remove((file, os.path.join(blog_target, 'source/_posts')))
            if not filecmp.cmp(dest_path, src_path, shallow=False):
                shutil.copy2(src_path, dest_path)
                change(f"{src_path} be updated to destnation now")
            else:
                debug(f"{src_path} already up to date")
        else:
            shutil.copy2(src_path, dest_path)
            change(f"{src_path} copied to destnation path")
    
    for file, root in dest_md_files:
        dest_path = os.path.join(root, file)
        os.remove(dest_path)
        change(f"{dest_path} removed")

    # Move image files
    image_source = os.path.join(source, 'images')
    image_target = os.path.join(blog_target, 'source/images')
    
    for root, _, files in os.walk(image_source):
        for file in files:
            src_path = os.path.join(root, file)
            dest_path = os.path.join(image_target, file)
            
            if os.path.exists(dest_path):
                if not filecmp.cmp(dest_path, src_path, shallow=False):
                    shutil.copy2(src_path, dest_path)
                    info(f"{src_path} copied to {dest_path}")
            else:
                shutil.copy2(src_path, dest_path)
                info(f"{src_path} copied to {dest_path}")
    
    # Remove extra image files in blog_target/source/_images
    for root, _, files in os.walk(image_target):
        for file in files:
            src_path = os.path.join(image_source, file)
            dest_path = os.path.join(root, file)
            if not os.path.exists(src_path):
                os.remove(dest_path)
                info(f"{dest_path} removed")
    
    success("move files finished")

def renew_files():
    info("renew files")
    # Traverse all .md files in blog_target/source/_posts directory and update them in source directory
    for root, _, files in os.walk(os.path.join(blog_target, 'source/_posts')):
        for file in files:
            if file.endswith('.md') and file != "README.md":
                src_path = os.path.join(source, file)
                dest_path = os.path.join(root, file)
                for src_root, _, src_files in os.walk(source):
                    if file in src_files:
                        src_path = os.path.join(src_root, file)
                        break
                if os.path.exists(src_path):
                    # Compare files, if different, copy
                    if not filecmp.cmp(dest_path, src_path, shallow=False):
                        shutil.copy2(dest_path, src_path)
                        print(f"{dest_path} copied to {src_path}")
                else:
                    shutil.copy2(dest_path, src_path)
                    print(f"{dest_path} copied to {src_path}")
    print(Fore.BLUE + f"[{time.localtime().tm_min}:]" + Style.RESET_ALL + " qblog: renew files finished")

def clean_and_generate():
    info("clean and generate")
    os.chdir(os.path.join(blog_target, '.'))
    subprocess.run(['npx', 'hexo', 'clean'])
    subprocess.run(['npx', 'hexo', 'generate'])
    success("clean and generate finished")

def start_server():
    info("hexo server")
    os.chdir(os.path.join(blog_target, '.'))
    subprocess.run(['npx', 'hexo', 'server'])

def deploy():
    info("hexo deploy")
    os.chdir(os.path.join(blog_target, '.'))
    subprocess.run(['npx', 'hexo', 'deploy'])

def git_commit():
    info("git commit")
    subprocess.run(['git', 'add', '.'])
    subprocess.run(['git', 'commit', '-m', "Daily reading experience"])
    success("git commit completed")

def git_push():
    info("git push")
    subprocess.run(['git', 'push'])
    success("git push completed")

# Get command-line argument
command = sys.argv[1] if len(sys.argv) > 1 else None

# Command control flow
if command == "-m":
    move_files()
elif command == "-r":
    renew_files()
elif command == "-s":
    if check_categorys():
        move_files()
        clean_and_generate()
        renew_files()
        start_server()
    else:
        print(Fore.RED + "[ERROR]" + Style.RESET_ALL + " qblog: Unmatch categorys, '-s' terminate.")
elif command == "-d":
    if check_categorys():
        move_files()
        clean_and_generate()
        renew_files()
        deploy()
    else:
        print(Fore.RED + "[ERROR]" + Style.RESET_ALL + " qblog: Unmatch categorys, '-d' terminate.")
elif command == "-Ss":
    start_server()
elif command == "-Sd":
    deploy()
elif command == "-c":
    clean_and_generate()
elif command == "-p":
    git_commit()
    git_push()
elif command == "-C":
    check_categorys()
else:
    print(Fore.RED + "[ERROR]" + Style.RESET_ALL + " qblog: Incorrect parameter list.")


