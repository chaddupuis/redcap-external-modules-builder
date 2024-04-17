#!/usr/bin/env bash

# for each do git clone --branch [...] --depth 1 [repo url] 
# then rm -rf .git in clone directory
# then move into modules directory

##### FUNCTIONS ######
clean_up_previous_installs() {
    if [ -d $(pwd)/modules ]; then
        echo "previous modules are present... cleaning up..."
        rm -rf $(pwd)/modules/
        mkdir -p $(pwd)/modules
    else
        echo "no previous modules installed, ignoring..."
    fi
}

does_branch_exist() {
    #$1 is version $2 is repo url
    git ls-remote --exit-code ${2} refs/tags/${1} >/dev/null 2>&1
    if [ "$?" == "0" ]; then  # 0 is a match 2 is no match
        echo "BRANCH FOR ${1} - ${2} exists"
        return 0 # true exists
    else
        return 1 # not true 
    fi
}

clone_module_repo_branch_and_move_clean() {
    my_repo_data=("$@")
    # $@ is array with version, dir and repo-url
    # [0] is the tag/branch you want
    # [1] is the directory
    # [2] is the url
    my_valid_tag=""
    if does_branch_exist "${my_repo_data[0]}" "${my_repo_data[2]}"; then
        echo "found without v"
        my_valid_tag="${my_repo_data[0]}"
    elif does_branch_exist "v${my_repo_data[0]}" "${my_repo_data[2]}"; then
        echo "found with v"
        my_valid_tag="v${my_repo_data[0]}"
    else
        echo "problem finding repo ${my_repo_data[2]}... exiting..."
        exit 1
    fi
    if [ -d ./modules/${my_repo_data[1]}_v${my_repo_data[0]} ]; then
        echo "removing existing directory for ${my_repo_data[1]}..."
        rm -rf ./modules/${my_repo_data[1]}_v${my_repo_data[0]}
    fi
    echo "PULLING ${my_valid_tag} -${my_repo_data[2]} module and cleaning up"
    git clone -c advice.detachedHead=false -q --branch ${my_valid_tag} --depth 1 ${my_repo_data[2]} ./modules/${my_repo_data[1]}_v${my_repo_data[0]} 
    echo "removing .git .gitignore from module directory"

    rm -rf ./modules/${my_repo_data[1]}_v${my_repo_data[0]}/.git
    rm -f ./modules/${my_repo_data[1]}_v${my_repo_data[0]}/.gitignore
    echo "${my_repo_data[1]} download complete..."    
}

# first clean up to avoid multiple versions, etc.
clean_up_previous_installs

### ALL INSTALLED MOODULES
# repo_url # tag branch $ directory
## the directories are only known? when you installed it and find what it does then _vxxx
## if you want multiple versions of the same module just do another line with the other version(s)
### Admin Dashboard
admin_dashboard=("4.1.2" "admin_dash" "https://github.com/ui-icts/redcap-admin-dashboard.git")
clone_module_repo_branch_and_move_clean "${admin_dashboard[@]}"

### Annotated PDF
annotated_pdf=("1.2.0" "annotated_pdf" "https://github.com/lsgs/redcap-annotated-pdf.git")
clone_module_repo_branch_and_move_clean "${annotated_pdf[@]}"

### Auto DAGs
auto_dags=("1.2.3" "auto_dags" "https://github.com/vanderbilt-redcap/auto-dags-module.git")
clone_module_repo_branch_and_move_clean "${auto_dags[@]}"

### Custom Record Auto-Numbering
custom_record_num=("1.0.6" "record_autonumber" "https://github.com/lsgs/redcap-record-autonumbering.git")
clone_module_repo_branch_and_move_clean "${custom_record_num[@]}"

### Data Entry Trigger Builder
data_entry_trigger=("2.1.3" "data_entry_trigger_builder" "https://github.com/BCCHR-IT/data-entry-trigger-builder.git")
clone_module_repo_branch_and_move_clean "${data_entry_trigger[@]}"

### PDF Injector
pdf_injector=("3.1.0" "pdf_injector" "https://github.com/Research-IT-Swiss-TPH/redcap-pdf-injector.git")
clone_module_repo_branch_and_move_clean "${pdf_injector[@]}"

### Shazam
shazam=("1.3.13" "shazam" "https://github.com/susom/redcap-em-shazam.git")
clone_module_repo_branch_and_move_clean "${shazam[@]}"

# finished
echo "all modules should be downloaded now... verify..."

echo "NOW - running compose for dependencies in all modules"
docker compose up

echo "composer done -- finding vendor dirs"
find ./modules -type d -name 'vendor'

docker compose down
docker image rm rc-composer-builder-image --force

echo "cleaning up - should be done ... verify..."
