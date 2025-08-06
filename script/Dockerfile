ARG IMAGE_TAG='3.12.3'
# 基础镜像
FROM deccr.ccs.tencentyun.com/crawler-dev/python:$IMAGE_TAG

# 重新声明构建参数（否则FROM后会失效）
ARG GIT_LINK
ARG FRIDA_EGG
ARG FRIDA_EGG_PATH
ARG PROJECT_NAME=crawler

#MAINTAINER Logan.Jin: loganjincn@126.com
LABEL maintainer="Logan.Jin <loganjincn@126.com>"


ENV PYTHONIOENCODING=utf-8 TZ=Asia/Shanghai LANG=C.UTF-8 \
    PROJECT_NAME=$PROJECT_NAME \
    SSH_KEY_CHECK=false SSH_KEYGEN=true CRONTAB=""  APT_SOURCE="" PIP_SOURCE=""

RUN if [ -n "$FRIDA_EGG" ]; then wget -O $FRIDA_EGG_PATH $FRIDA_EGG; fi \
    && export VENV_DIR="$HOME/.virtualenvs/$PROJECT_NAME" \
    && python3 -m venv $VENV_DIR \
    # 将venv目录添加到环境变量
    && export PATH="$VENV_DIR/bin":$PATH \
    && git clone $GIT_LINK $HOME/$PROJECT_NAME/ \
    && python -m pip install --upgrade pip \
    && if [ -f $HOME/$PROJECT_NAME/requirements.txt ]; then \
         pip install -r $HOME/$PROJECT_NAME/requirements.txt; \
         # 新增 playwright 检测逻辑
         if pip list 2>/dev/null | grep -q playwright; then \
             echo 'playwright is installed, installing chrome... ' && \
             playwright install chrome; \
         fi; \
         # 新增 drm工具安装逻辑
         if pip list 2>/dev/null | grep -q pywidevine; then \
             echo 'Installing DRM tools...'; \
             wget -q https://github.com/LoganJinDev/Images/raw/refs/heads/master/script/mi8_android10_l3.wvd -O /usr/local/bin/mi8_android10_l3.wvd; \
             wget -q https://github.com/LoganJinDev/Images/raw/refs/heads/master/script/mp4decrypt_linux -O /usr/local/bin/mp4decrypt; \
             chmod +x /usr/local/bin/mp4decrypt; \
             wget -qO- https://github.com/nilaoda/N_m3u8DL-RE/releases/download/v0.3.0-beta/N_m3u8DL-RE_v0.3.0-beta_linux-x64_20241203.tar.gz | tar -xz -C /usr/local/bin/; \
             chmod +x /usr/local/bin/N_m3u8DL-RE; \
         fi; \
       fi \
    && if [ -f $FRIDA_EGG_PATH ]; then \
         rm -rf $FRIDA_EGG_PATH; \
       fi \
    && pip cache purge \
    && echo '#!/bin/bash' > /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo 'if [ ! -f /tmp/"$PROJECT_NAME"-initialized ]; then' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '  echo "Performing one-time $PROJECT_NAME initialization tasks..."' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '  if [ "$USE_USER" = "root" ]; then' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 将venv环境变量添加到root ~/.profile
    && echo '    echo "export PATH=$HOME/.virtualenvs/$PROJECT_NAME/bin:$PATH" >> ~/.profile' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 将venv环境变量添加到 root用户 crontab
    && echo '    echo "PATH=$HOME/.virtualenvs/$PROJECT_NAME/bin:$PATH" >> /var/spool/cron/crontabs/root' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '  else' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 拷贝root用户venv 及替换root用户字符串
    && echo '    cp -r /root/.virtualenvs/$PROJECT_NAME/ /home/$USE_USER/.virtualenvs/' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    chown $USE_USER:$USE_USER -R /home/$USE_USER/.virtualenvs/$PROJECT_NAME/' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    grep_files=$(grep -rl "/root/.virtualenvs" /home/$USE_USER/.virtualenvs/$PROJECT_NAME/bin/)' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    sed -i s@/root/.virtualenvs@/home/$USE_USER/.virtualenvs@g $grep_files' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 将venv环境变量添加到普通用户 ~/.profile
    && echo '    echo "export PATH=/home/$USE_USER/.virtualenvs/$PROJECT_NAME/bin:$PATH" >> /home/$USE_USER/.profile' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 将venv环境变量添加到 普通用户 crontab
    && echo '    chown root:crontab -R /var/spool/cron/crontabs/$USE_USER' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    echo "PATH=/home/$USE_USER/.virtualenvs/$PROJECT_NAME/bin:$PATH" >> /var/spool/cron/crontabs/$USE_USER' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    chown $USE_USER:crontab -R /var/spool/cron/crontabs/$USE_USER' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    rm -rf /root/.virtualenvs/$PROJECT_NAME' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    mv $HOME/$PROJECT_NAME/ /home/$USE_USER/$PROJECT_NAME/' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '    chown $USE_USER:$USE_USER -R /home/$USE_USER/$PROJECT_NAME/' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '  fi' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo '  touch /tmp/"$PROJECT_NAME"-initialized' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && echo 'fi' >> /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    && chmod +x /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh \
    # 将/usr/local/bin/"$PROJECT_NAME"-entrypoint.sh 添加到基础镜像入口脚本 /usr/local/bin/docker-entrypoint.sh 中执行
    && sed -i '/^exec "\$@"/i /bin/bash /usr/local/bin/"$PROJECT_NAME"-entrypoint.sh' /usr/local/bin/docker-entrypoint.sh


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/bin/bash"]