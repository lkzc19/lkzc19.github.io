---
title: Gitee图床
date: 2023-09-06 20:59:00
tags: Python
---

# 0 前言

写博客，特别是私人博客，图床是必不可少。最常见的是使用 PicGo 配合公有云做图床。但是直接使用别人现成的属实无趣。正好最近需要用到 Python，用 Python 写一个上传图片后可以返回图片链接的工具练练手。图床就选择使用 Gitee。

# 1 正文

## Gitee Open API

这个工具最大的难点就是如何将图片推送到仓库，且获取到推送上的图片的地址。在翻阅 Gitee 的 open API 后找到一个[接口](https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoContentsPath)，可以满足这个要求。

```markdown
POST  https://gitee.com/api/v5/repos/{owner}/{repo}/contents/{path}
```

唯一需要解释的参数就是 `path` ，是指在仓库中的地址。

接口返回的数据 `download_url` 就是图片的路径。

## access_token 获取

![access_token获取](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-07-20-56-04.png)

生成令牌时按需给权限即可。拿到 `assess_token` 后，可将其配置到环境变量中，如代码分享给别人时，也不会将 `assess_token` 泄漏。

## 码

代码不是很多，所以就全部放在文章中，没有上传到git上。

```python
import argparse
import base64
import sys
from datetime import datetime
import os
import requests


if __name__ == '__main__':
    # 入参
    parser = argparse.ArgumentParser(description='gitee图床工具')
    parser.add_argument('img', help='图片地址')
    args = parser.parse_args()

    # 读取文件
    with open(args.img, 'rb') as it:
        file = it.read()

    # 判断是否是图片
    _, extension = os.path.splitext(args.img)
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']
    if extension.lower() not in image_extensions:
        print('[' + extension + ']文件非图片，不能上传')
        sys.exit(1)

    # 上传到gitee上的文件名 上传的频率不是很高, 使用秒即可
    filename = datetime.now().strftime("%Y-%m-%d-%H-%M-%S") + extension

    path_params = {
        'owner': 'lkzc19',
        'repo': 'zimg',
        'path': 'drinkice/' + filename
    }
    body = {
        'access_token': os.environ.get('GITEE_ACCESS_TOKEN'),
        'content': base64.b64encode(file).decode('utf-8'), # 将图片文件转换为 Base64 编码
        'message': 'feat: 上传图片'
    }
    # https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoContentsPath
    response = requests.post(
        'https://gitee.com/api/v5/repos/{owner}/{repo}/contents/{path}'.format_map(path_params),
        json=body
    )
    if not response.ok:
        print('上传失败: ' + response.json()['message'])
        sys.exit(1)

    # 成功输出图片地址
    print('上传成功')
    gitee_img_url = response.json()['content']['download_url']
    print('markdown: \t' + ('![]({})'.format(gitee_img_url)))
    print('URL: \t\t' + gitee_img_url)
```

目前我使用，只是作为本个人站图床使用。所以 `path` 就写死一个路径，文件名直接用日期时间，保证不重名即可。

## 配置使用

代码写完其实就可以使用。

```bash
python3 zimg.py <图片路径>
```

但是为了方便的使用，使用 Shell 脚本将其再封装一层，且将 Shell 脚本配置到环境变量中。

```bash
#!/bin/bash

python3 ~/bin/lib/zimg.py $1
```

之后就可方便的调用该脚本

![调用 Shell 脚本](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-07-20-56-26.png)

# 3. 注意点

如果上传成功且图片也在Gitee上后，应该是因为仓库**没有公开**，所以导致图片在外界是访问不了的。
