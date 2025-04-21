import defaultPicture from "./../assets/profile.png";
import React from 'react';
import { Link } from "react-router-dom";
import { withTranslation } from "react-i18next";
import ProfileImage from "./ProfileImage";

const UserTableRow = (props) => {
    const { t, user } = props; // Получаем `t` из пропсов
    const { username, name, surname, email, image, roles } = user; // Добавляем `roles`

    return (
        <tr key={username}>
            <td scope="row">
                <ProfileImage
                    width="32px"
                    height="32px"
                    imageSource={image ? image : defaultPicture}
                    username={username}
                />
            </td>
            <td>{username}</td>
            <td>{name}</td>
            <td>{surname}</td>
            <td>{email}</td>
            <td>{roles && roles.length > 0 ? roles.join(', ') : t('No Roles')}</td> {/* Отображаем роли через запятую */}
            <td>
                <Link
                    to={'/user/' + username}
                    className="btn btn-wm btn-success"
                >
                    {t('Open')} {/* Перевод кнопки */}
                </Link>
            </td>
        </tr>
    );
};

export default withTranslation()(UserTableRow);